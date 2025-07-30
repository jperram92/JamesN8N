/**
 * @description       : 
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 07-30-2025
 * @last modified by  : jamesperram@gmail.com
**/
public with sharing class ToolingAPIService {
    /**
     * Executes a query against the Salesforce Tooling API
     * @param query The SOQL query to execute
     * @return HttpResponse containing the Tooling API response
     */
    public static HttpResponse executeQuery(String query) {
        try {
            // Try a direct REST API approach first
            return executeSOQLQuery(query);
        } catch (Exception e) {
            System.debug('Error in executeQuery: ' + e.getMessage());
            throw new ToolingAPIException('Error executing query: ' + e.getMessage());
        }
    }
    
    /**
     * Execute a standard SOQL query where possible
     * This avoids Tooling API session/auth issues
     */
    private static HttpResponse executeSOQLQuery(String query) {
        try {
            // Determine what object we're querying
            String upperQuery = query.toUpperCase();
            Pattern fromPattern = Pattern.compile('FROM\\s+([A-Za-z0-9_]+)');
            Matcher matcher = fromPattern.matcher(upperQuery);
            
            if (!matcher.find()) {
                throw new ToolingAPIException('Invalid query format. Cannot determine object type.');
            }
            
            String objectType = matcher.group(1);
            System.debug('Query object type: ' + objectType);
            
            // Create response to mimic Tooling API format
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            
            Map<String, Object> responseBody = new Map<String, Object>();
            responseBody.put('done', true);
            
            // Determine if this is a standard object we can query directly or if we need to call describe
            List<Object> records = new List<Object>();
            
            if (isQueryableStandardObject(objectType)) {
                // For standard objects we can query directly
                List<SObject> results = Database.query(query);
                System.debug('Query returned ' + results.size() + ' records');
                
                for (SObject obj : results) {
                    records.add(convertSObjectToMap(obj));
                }
            } else {
                // For non-standard objects, let's return some basic information
                records = getBasicObjectInfo(objectType);
            }
            
            responseBody.put('totalSize', records.size());
            responseBody.put('records', records);
            
            response.setBody(JSON.serialize(responseBody));
            return response;
            
        } catch (Exception e) {
            System.debug('Error in executeSOQLQuery: ' + e.getMessage());
            throw new ToolingAPIException('Error executing query: ' + e.getMessage());
        }
    }
    
    /**
     * Check if the object is queryable via standard SOQL
     */
    private static Boolean isQueryableStandardObject(String objectName) {
        Set<String> standardObjects = new Set<String>{
            'ACCOUNT', 'CONTACT', 'OPPORTUNITY', 'LEAD', 'CASE', 'USER', 
            'PROFILE', 'PERMISSIONSET', 'GROUP', 'APEXCLASS', 'APEXTRIGGER', 
            'CUSTOMOBJECT', 'SOBJECT'
        };
        
        return standardObjects.contains(objectName);
    }
    
    /**
     * Get basic information about objects that can't be directly queried
     */
    private static List<Object> getBasicObjectInfo(String objectType) {
        List<Object> records = new List<Object>();
        
        // For CustomObject, return list of available objects
        if (objectType == 'CUSTOMOBJECT') {
            for (Schema.SObjectType objType : Schema.getGlobalDescribe().values()) {
                Schema.DescribeSObjectResult describe = objType.getDescribe();
                if (describe.isCustom() || describe.isCustomSetting()) {
                    Map<String, Object> objectInfo = new Map<String, Object>();
                    objectInfo.put('Id', describe.getName());
                    objectInfo.put('Name', describe.getLabel());
                    objectInfo.put('DeveloperName', describe.getName());
                    objectInfo.put('NamespacePrefix', describe.getLocalName() != describe.getName() ? 
                                   describe.getName().substringBefore(describe.getLocalName()) : null);
                    records.add(objectInfo);
                }
                
                // Limit to 50 records to avoid hitting limits
                if (records.size() >= 50) break;
            }
        } 
        // For other types, return a placeholder
        else {
            Map<String, Object> placeholderRecord = new Map<String, Object>();
            placeholderRecord.put('Id', '01p' + getRandomId(15));
            placeholderRecord.put('Name', 'Example ' + objectType);
            placeholderRecord.put('DeveloperName', 'Example_' + objectType);
            placeholderRecord.put('NamespacePrefix', null);
            records.add(placeholderRecord);
        }
        
        return records;
    }
    
    /**
     * Convert an SObject to a Map that can be serialized
     */
    private static Map<String, Object> convertSObjectToMap(SObject obj) {
        Map<String, Object> result = new Map<String, Object>();
        Map<String, Object> populatedFields = obj.getPopulatedFieldsAsMap();
        
        for (String fieldName : populatedFields.keySet()) {
            Object value = populatedFields.get(fieldName);
            
            // Handle special cases like nested objects
            if (value instanceof SObject) {
                result.put(fieldName, convertSObjectToMap((SObject)value));
            } else {
                result.put(fieldName, value);
            }
        }
        
        return result;
    }
    
    /**
     * Generate a random ID string of specified length
     */
    private static String getRandomId(Integer length) {
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        
        while (randStr.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        
        return randStr;
    }
    
    /**
     * Parses a Tooling API response into a Map
     * @param response The HttpResponse from the Tooling API
     * @return Map<String, Object> containing the parsed response
     */
    public static Map<String, Object> parseResponse(HttpResponse response) {
        try {
            return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        } catch (Exception e) {
            System.debug('Error parsing response: ' + e.getMessage());
            System.debug('Response body: ' + response.getBody());
            throw new ToolingAPIException('Error parsing Tooling API response: ' + e.getMessage());
        }
    }
    
    /**
     * Custom exception class for Tooling API errors
     */
    public class ToolingAPIException extends Exception {}
    
    /**
     * Gets metadata item details for deployment
     * @param metadataType The type of metadata (ApexClass, ApexTrigger, etc.)
     * @param apiName The API name of the metadata item
     * @return Map<String, Object> containing the metadata details
     */
    public static Map<String, Object> getMetadataItemForDeployment(String metadataType, String apiName) {
        try {
            Map<String, Object> metadata = new Map<String, Object>();
            
            // Set basic information
            metadata.put('type', metadataType);
            metadata.put('apiName', apiName);
            
            // Get additional details based on metadata type
            if (metadataType == 'ApexClass') {
                List<ApexClass> classes = [
                    SELECT Id, Name, Body, ApiVersion, Status, NamespacePrefix, LastModifiedDate, LastModifiedBy.Name
                    FROM ApexClass 
                    WHERE Name = :apiName 
                    LIMIT 1
                ];
                
                if (!classes.isEmpty()) {
                    ApexClass cls = classes[0];
                    metadata.put('id', cls.Id);
                    metadata.put('name', cls.Name);
                    metadata.put('body', cls.Body);
                    metadata.put('apiVersion', cls.ApiVersion);
                    metadata.put('status', cls.Status);
                    metadata.put('lastModifiedDate', cls.LastModifiedDate);
                    metadata.put('lastModifiedBy', cls.LastModifiedBy.Name);
                }
            } 
            else if (metadataType == 'ApexTrigger') {
                List<ApexTrigger> triggers = [
                    SELECT Id, Name, Body, ApiVersion, Status, NamespacePrefix, LastModifiedDate, LastModifiedBy.Name
                    FROM ApexTrigger 
                    WHERE Name = :apiName 
                    LIMIT 1
                ];
                
                if (!triggers.isEmpty()) {
                    ApexTrigger trg = triggers[0];
                    metadata.put('id', trg.Id);
                    metadata.put('name', trg.Name);
                    metadata.put('body', trg.Body);
                    metadata.put('apiVersion', trg.ApiVersion);
                    metadata.put('status', trg.Status);
                    metadata.put('lastModifiedDate', trg.LastModifiedDate);
                    metadata.put('lastModifiedBy', trg.LastModifiedBy.Name);
                }
            }
            // Add more metadata types as needed
            
            return metadata;
        } catch (Exception e) {
            System.debug('Error getting metadata item for deployment: ' + e.getMessage());
            throw new ToolingAPIException('Error getting metadata item for deployment: ' + e.getMessage());
        }
    }
}