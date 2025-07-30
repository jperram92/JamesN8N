/**
 * @description       : Controller for handling metadata deployments
 * @author            : jamesperram@gmail.com
 * @group             : 
 * @last modified on  : 07-30-2025
 * @last modified by  : jamesperram@gmail.com
**/
public with sharing class MetadataDeploymentController {
    
    /**
     * Prepare metadata components for deployment
     * @param components List of components to prepare for deployment
     * @return List<Map<String, Object>> containing prepared components
     */
    @AuraEnabled
    public static List<Map<String, Object>> prepareDeployment(List<Map<String, Object>> components) {
        try {
            List<Map<String, Object>> preparedComponents = new List<Map<String, Object>>();
            
            for (Map<String, Object> component : components) {
                String metadataType = (String)component.get('type');
                String apiName = (String)component.get('apiName');
                
                Map<String, Object> metadata = ToolingAPIService.getMetadataItemForDeployment(metadataType, apiName);
                
                // Add deployment-specific information
                metadata.put('deploymentComment', component.get('deploymentComment'));
                preparedComponents.add(metadata);
            }
            
            return preparedComponents;
        } catch (Exception e) {
            System.debug('Error preparing deployment: ' + e.getMessage());
            throw new AuraHandledException('Error preparing deployment: ' + e.getMessage());
        }
    }
    
    /**
     * Deploy metadata components
     * @param deploymentName Name of the deployment
     * @param components List of components to deploy
     * @param deploymentOptions Map of deployment options
     * @return String Deployment ID or status
     */
    @AuraEnabled
    public static String deployComponents(String deploymentName, List<Map<String, Object>> components, Map<String, Object> deploymentOptions) {
        try {
            // In a real implementation, this would use Metadata API or Change Sets
            // For this example, we'll just log what would be deployed
            System.debug('Deployment Name: ' + deploymentName);
            System.debug('Components to Deploy: ' + JSON.serialize(components));
            System.debug('Deployment Options: ' + JSON.serialize(deploymentOptions));
            
            // Prepare a simulated deployment response
            String deploymentId = 'DEP-' + Datetime.now().getTime();
            
            // Create the deployment record
            Deployment__c deployment = new Deployment__c(
                Name = deploymentName,
                Deployment_ID__c = deploymentId,
                Deployment_Date__c = Datetime.now(),
                Status__c = 'Pending',
                Test_Level__c = (String)deploymentOptions.get('testLevel'),
                Check_Only__c = (Boolean)deploymentOptions.get('checkOnly'),
                Rollback_on_Error__c = (Boolean)deploymentOptions.get('rollbackOnError'),
                Ignore_Warnings__c = (Boolean)deploymentOptions.get('ignoreWarnings'),
                Deployment_Comments__c = (String)deploymentOptions.get('deploymentComments')
            );
            
            insert deployment;
            
            // Create deployment component records
            List<Deployment_Component__c> deploymentComponents = new List<Deployment_Component__c>();
            
            for (Map<String, Object> component : components) {
                // Convert lastModifiedDate properly if it exists
                Datetime lastModDate = null;
                if (component.get('lastModifiedDate') != null) {
                    try {
                        // If it's a string, parse it
                        if (component.get('lastModifiedDate') instanceof String) {
                            String dateStr = (String)component.get('lastModifiedDate');
                            // Try to parse the string to a Datetime
                            if (dateStr != null && dateStr.trim() != '') {
                                // Handle ISO format date string
                                lastModDate = (Datetime)JSON.deserialize('"' + dateStr + '"', Datetime.class);
                            }
                        } 
                        // If it's already a Datetime
                        else if (component.get('lastModifiedDate') instanceof Datetime) {
                            lastModDate = (Datetime)component.get('lastModifiedDate');
                        }
                    } catch (Exception e) {
                        System.debug('Error converting lastModifiedDate: ' + e.getMessage());
                        // Continue with null date if conversion fails
                    }
                }
                
                Deployment_Component__c deploymentComponent = new Deployment_Component__c(
                    Deployment__c = deployment.Id,
                    Name = (String)component.get('name'),
                    API_Name__c = (String)component.get('apiName'),
                    Type__c = (String)component.get('type'),
                    Comment__c = (String)component.get('deploymentComment'),
                    Last_Modified_Date__c = lastModDate
                );
                
                deploymentComponents.add(deploymentComponent);
            }
            
            if (!deploymentComponents.isEmpty()) {
                insert deploymentComponents;
            }
            
            // Return the deployment ID to the LWC component
            return deploymentId;
        } catch (Exception e) {
            throw new AuraHandledException('Error deploying components: ' + e.getMessage());
        }
    }
    
    /**
     * Get deployment status
     * @param deploymentId ID of the deployment
     * @return Map<String, Object> containing deployment status
     */
    @AuraEnabled
    public static Map<String, Object> getDeploymentStatus(String deploymentId) {
        try {
            // In a real implementation, this would check the status of a deployment
            Map<String, Object> status = new Map<String, Object>();
            status.put('deploymentId', deploymentId);
            status.put('status', 'Completed');
            status.put('success', true);
            status.put('completedDate', Datetime.now());
            
            return status;
        } catch (Exception e) {
            System.debug('Error getting deployment status: ' + e.getMessage());
            throw new AuraHandledException('Error getting deployment status: ' + e.getMessage());
        }
    }
}
