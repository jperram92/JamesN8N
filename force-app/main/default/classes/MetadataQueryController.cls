/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 07-30-2025
 * @last modified by  : jamesperram@gmail.com
**/
public with sharing class MetadataQueryController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getMetadataTypes() {
        List<String> metadataTypes = new List<String>{
            'ApexClass', 'ApexTrigger', 'CustomObject', 'CustomField', 
            'Layout', 'ValidationRule', 'Flow', 'ApexPage',
            'LightningComponentBundle', 'AuraDefinitionBundle'
        };
        return metadataTypes;
    }
    
    @AuraEnabled
    public static List<Map<String, Object>> queryMetadata(String metadataType, String searchTerm) {
        try {
            System.debug('Querying metadata type: ' + metadataType + ', searchTerm: ' + searchTerm);
            
            // Construct the SOQL query based on the metadata type
            String query = constructQueryForType(metadataType, searchTerm);
            System.debug('Constructed query: ' + query);
            
            // Execute the query using the Tooling API
            HttpResponse response = ToolingAPIService.executeQuery(query);
            Map<String, Object> responseMap = ToolingAPIService.parseResponse(response);
            
            List<Object> records = (List<Object>) responseMap.get('records');
            System.debug('Query returned ' + (records != null ? records.size() : 0) + ' records');
            
            List<Map<String, Object>> formattedResults = formatResults(records, metadataType);
            return formattedResults;
        } catch (Exception e) {
            System.debug('Error in queryMetadata: ' + e.getMessage() + ' / ' + e.getStackTraceString());
            throw new AuraHandledException('Error querying metadata: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String executeToolingQuery(String query) {
        try {
            System.debug('Executing tooling query: ' + query);
            
            // Use the ToolingAPIService to execute the query
            HttpResponse response = ToolingAPIService.executeQuery(query);
            
            // Parse the response
            Map<String, Object> responseMap = ToolingAPIService.parseResponse(response);
            
            // Extract the records
            List<Object> records = (List<Object>) responseMap.get('records');
            System.debug('Tooling query returned ' + (records != null ? records.size() : 0) + ' records');
            
            // Return the records as a JSON string
            return JSON.serialize(records);
        } catch (Exception e) {
            System.debug('Error in executeToolingQuery: ' + e.getMessage() + ' / ' + e.getStackTraceString());
            throw new AuraHandledException('Error executing query: ' + e.getMessage());
        }
    }
    
    private static String constructQueryForType(String metadataType, String searchTerm) {
        String query;
        searchTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';
        
        switch on metadataType {
            when 'ApexClass' {
                query = 'SELECT Id, Name, ApiVersion, NamespacePrefix, LastModifiedDate, LastModifiedBy.Name FROM ApexClass';
                if (String.isNotBlank(searchTerm) && searchTerm != '%%') {
                    query += ' WHERE Name LIKE \'' + searchTerm + '\'';
                }
            }
            when 'ApexTrigger' {
                query = 'SELECT Id, Name, ApiVersion, NamespacePrefix, LastModifiedDate, LastModifiedBy.Name FROM ApexTrigger';
                if (String.isNotBlank(searchTerm) && searchTerm != '%%') {
                    query += ' WHERE Name LIKE \'' + searchTerm + '\'';
                }
            }
            when 'CustomObject' {
                query = 'SELECT Id, DeveloperName, NamespacePrefix, LastModifiedDate, LastModifiedBy.Name FROM CustomObject';
                if (String.isNotBlank(searchTerm) && searchTerm != '%%') {
                    query += ' WHERE DeveloperName LIKE \'' + searchTerm + '\'';
                }
            }
            when 'CustomField' {
                query = 'SELECT Id, DeveloperName, TableEnumOrId, NamespacePrefix, LastModifiedDate, LastModifiedBy.Name FROM CustomField';
                if (String.isNotBlank(searchTerm) && searchTerm != '%%') {
                    query += ' WHERE DeveloperName LIKE \'' + searchTerm + '\'';
                }
            }
            when else {
                // Default query structure for other types
                query = 'SELECT Id, DeveloperName, NamespacePrefix, LastModifiedDate FROM ' + metadataType;
                if (String.isNotBlank(searchTerm) && searchTerm != '%%') {
                    query += ' WHERE DeveloperName LIKE \'' + searchTerm + '\'';
                }
            }
        }
        
        query += ' ORDER BY LastModifiedDate DESC LIMIT 50';
        return query;
    }
    
    private static List<Map<String, Object>> formatResults(List<Object> records, String metadataType) {
        List<Map<String, Object>> formattedResults = new List<Map<String, Object>>();
        
        for (Object rec : records) {
            Map<String, Object> record = (Map<String, Object>) rec;
            Map<String, Object> formattedRecord = new Map<String, Object>();
            
            // Common fields
            formattedRecord.put('id', record.get('Id'));
            formattedRecord.put('type', metadataType);
            
            // Format the last modified date
            if (record.get('LastModifiedDate') != null) {
                String dateStr = String.valueOf(record.get('LastModifiedDate'));
                // The original code had: DateTime dt = DateTime.valueOf(dateStr.replace('T', ' ').replace('Z', ''));
                // However, it's safer and more robust to use the parseDateTime method for consistency
                DateTime dt = parseDateTime(dateStr); 
                if (dt != null) {
                    formattedRecord.put('lastModified', dateStr); // Keep original for reference if needed
                    formattedRecord.put('formattedDate', dt.format('MMM dd, yyyy, hh:mm a')); // Match wrapper format
                } else {
                    formattedRecord.put('lastModified', dateStr);
                    formattedRecord.put('formattedDate', dateStr); // Fallback if parsing fails
                }
            }
            
            // Type-specific handling
            if (metadataType == 'CustomField') {
                formattedRecord.put('name', record.get('DeveloperName'));
                formattedRecord.put('apiName', record.get('TableEnumOrId') + '.' + record.get('DeveloperName'));
            } else if (metadataType == 'CustomObject') {
                formattedRecord.put('name', record.get('DeveloperName'));
                formattedRecord.put('apiName', record.get('DeveloperName'));
            } else {
                formattedRecord.put('name', record.containsKey('Name') ? record.get('Name') : record.get('DeveloperName'));
                formattedRecord.put('apiName', record.containsKey('DeveloperName') ? record.get('DeveloperName') : record.get('Name'));
            }
            
            formattedResults.add(formattedRecord);
        }
        
        return formattedResults;
    }
    
    /**
     * Parses a datetime string from the API
     * @param dateTimeStr The datetime string from the API
     * @return DateTime The parsed DateTime object
     */
    private static DateTime parseDateTime(String dateTimeStr) {
        try {
            // Parse ISO format: 2023-01-01T12:00:00.000Z
            if (dateTimeStr != null && dateTimeStr.endsWith('Z')) {
                dateTimeStr = dateTimeStr.removeEnd('Z');
                // Handle potential milliseconds for more robust parsing
                if (dateTimeStr.contains('.')) {
                    dateTimeStr = dateTimeStr.substringBefore('.');
                }
                
                List<String> dateParts = dateTimeStr.split('T');
                List<String> dateComponents = dateParts[0].split('-');
                List<String> timeComponents = dateParts[1].split(':');
                
                Integer year = Integer.valueOf(dateComponents[0]);
                Integer month = Integer.valueOf(dateComponents[1]);
                Integer day = Integer.valueOf(dateComponents[2]);
                
                Integer hour = Integer.valueOf(timeComponents[0]);
                Integer minute = Integer.valueOf(timeComponents[1]);
                Integer second = Integer.valueOf(timeComponents[2]);
                
                return DateTime.newInstanceGmt(year, month, day, hour, minute, second);
            }
            return null;
        } catch (Exception e) {
            // Log the error or handle it more gracefully if needed
            System.debug('Error parsing datetime string "' + dateTimeStr + '": ' + e.getMessage());
            return null;
        }
    }
    
    /**
     * Wrapper class for metadata component information
     */
    public class MetadataWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String type;
        @AuraEnabled public String apiName;
        @AuraEnabled public DateTime lastModifiedDate;
        @AuraEnabled public String formattedDate {
            get {
                if (lastModifiedDate != null) {
                    return lastModifiedDate.format('MMM dd, yyyy, hh:mm a');
                }
                return '';
            }
        }
        // Add a constructor if you plan to create instances of this wrapper internally
        public MetadataWrapper(String id, String name, String type, String apiName, DateTime lastModifiedDate) {
            this.id = id;
            this.name = name;
            this.type = type;
            this.apiName = apiName;
            this.lastModifiedDate = lastModifiedDate;
        }
    }
}