# Comprehensive Action Plan for Declarative Metadata Deployer Implementation

## 1. Custom Objects Setup

First, we need to create the custom objects to store deployment data:

### 1.1. Deployment__c Object:
- **Fields:**
  - Name (Auto-Number): Format "DEP-{0000}"
  - Status__c (Picklist): Values [Pending, InProgress, Succeeded, SucceededPartial, Failed, Canceling, Canceled]
  - Source_Org_Alias__c (Text): Source org identifier
  - Target_Org_Alias__c (Text): Target org identifier
  - Deployment_ID__c (Text): Metadata API deployment ID
  - User_Comments__c (Long Text Area): User's notes about deployment
  - Deployment_Log__c (Rich Text Area): Detailed logs of deployment process
  - Check_Only__c (Checkbox): For validation deployments
  - Run_Tests__c (Text Area): List of Apex test classes to run
  - Test_Level__c (Picklist): [NoTestRun, RunSpecifiedTests, RunLocalTests, RunAllTestsInOrg]
  - Rollback_On_Error__c (Checkbox): Rollback entire deployment on error
  - Ignore_Warnings__c (Checkbox): Continue deployment even if warnings occur

### 1.2. Metadata_Selection__c Object:
- **Fields:**
  - Name (Text): Human-readable name of metadata component
  - Type__c (Picklist): Metadata type values [ApexClass, Flow, CustomObject, etc.]
  - API_Name__c (Text): API name of component
  - Deployment__c (Master-Detail to Deployment__c): Link to parent deployment
  - Source_Org_Component_ID__c (Text): Component ID from source org
  - Component_Detail__c (Long Text Area): Optional snippet/preview of metadata

## 2. Apex Classes Development

### 2.1. MetadataQueryController:
This class will be responsible for querying metadata using the Tooling API:

```apex
public with sharing class MetadataQueryController {
    // Method to query metadata by type and search term
    @AuraEnabled
    public static List<MetadataWrapper> queryMetadata(String metadataType, String searchTerm) {
        // Implement Tooling API query logic
    }
    
    // Method to get available metadata types
    @AuraEnabled
    public static List<String> getMetadataTypes() {
        // Return list of supported metadata types
    }
    
    // Wrapper class for returning metadata info
    public class MetadataWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String type;
        @AuraEnabled public String apiName;
        @AuraEnabled public DateTime lastModifiedDate;
        // Other relevant fields
    }
}
```

### 2.2. DeploymentController:
This class will handle saving deployment records and initiating deployments:

```apex
public with sharing class DeploymentController {
    // Method to create deployment record and save selections
    @AuraEnabled
    public static Id createDeployment(String targetOrg, List<MetadataQueryController.MetadataWrapper> selections, 
                                     Boolean checkOnly, String testLevel, String runTests, 
                                     Boolean rollbackOnError, Boolean ignoreWarnings, String userComments) {
        // Create Deployment__c and related Metadata_Selection__c records
    }
    
    // Method to initiate deployment (callout to external middleware)
    @AuraEnabled
    public static void initiateDeployment(Id deploymentId) {
        // Perform callout to external middleware
    }
    
    // Method to get deployment status
    @AuraEnabled
    public static Deployment__c getDeploymentStatus(Id deploymentId) {
        // Query and return deployment status
    }
}
```

### 2.3. ToolingAPIService:
Utility class for Tooling API interactions:

```apex
public with sharing class ToolingAPIService {
    // Method to execute Tooling API query
    public static HttpResponse executeQuery(String query) {
        // Construct and execute HTTP request to Tooling API
    }
    
    // Method to parse Tooling API response
    public static Object parseResponse(HttpResponse response) {
        // Parse JSON response from Tooling API
    }
}
```

### 2.4. DeploymentCallbackEndpoint:
REST endpoint to receive status updates from middleware:

```apex
@RestResource(urlMapping='/deploymentCallback/*')
global with sharing class DeploymentCallbackEndpoint {
    @HttpPost
    global static void handleCallback() {
        // Process callback from middleware and update deployment status
    }
}
```

## 3. Lightning Web Component Development

### 3.1. declarativeMetadataDeployer LWC:
The main component for the user interface:

#### HTML Template (declarativeMetadataDeployer.html):
```html
<template>
    <lightning-card title="Declarative Metadata Deployer" icon-name="standard:product_item">
        <!-- Search and filter section -->
        <div class="slds-m-around_medium">
            <lightning-layout>
                <lightning-layout-item size="4" padding="horizontal-small">
                    <lightning-combobox
                        label="Metadata Type"
                        value={selectedMetadataType}
                        options={metadataTypeOptions}
                        onchange={handleTypeChange}
                    ></lightning-combobox>
                </lightning-layout-item>
                <lightning-layout-item size="8" padding="horizontal-small">
                    <lightning-input
                        type="search"
                        label="Search Metadata"
                        value={searchTerm}
                        onchange={handleSearchChange}
                    ></lightning-input>
                </lightning-layout-item>
            </lightning-layout>
        </div>
        
        <!-- Results datatable -->
        <div class="slds-m-around_medium">
            <lightning-datatable
                data={metadataResults}
                columns={columns}
                key-field="id"
                enable-infinite-loading
                onloadmore={loadMoreData}
                selected-rows={selectedRows}
                onrowselection={handleRowSelection}
            ></lightning-datatable>
        </div>
        
        <!-- Selected components section -->
        <div class="slds-m-around_medium">
            <h3 class="slds-text-heading_small">Selected Components</h3>
            <lightning-datatable
                data={selectedComponents}
                columns={selectedColumns}
                key-field="id"
                onrowaction={handleRemoveSelection}
            ></lightning-datatable>
        </div>
        
        <!-- Deployment configuration section -->
        <div class="slds-m-around_medium">
            <h3 class="slds-text-heading_small">Deployment Configuration</h3>
            <lightning-layout multiple-rows>
                <lightning-layout-item size="6" padding="around-small">
                    <lightning-input label="Target Org Alias" value={targetOrg} onchange={handleTargetOrgChange}></lightning-input>
                </lightning-layout-item>
                <lightning-layout-item size="6" padding="around-small">
                    <lightning-combobox
                        label="Test Level"
                        value={testLevel}
                        options={testLevelOptions}
                        onchange={handleTestLevelChange}
                    ></lightning-combobox>
                </lightning-layout-item>
                <lightning-layout-item size="12" padding="around-small">
                    <lightning-textarea label="Comments" value={userComments} onchange={handleCommentsChange}></lightning-textarea>
                </lightning-layout-item>
                <lightning-layout-item size="6" padding="around-small">
                    <lightning-input type="checkbox" label="Check Only" checked={checkOnly} onchange={handleCheckOnlyChange}></lightning-input>
                </lightning-layout-item>
                <lightning-layout-item size="6" padding="around-small">
                    <lightning-input type="checkbox" label="Rollback On Error" checked={rollbackOnError} onchange={handleRollbackChange}></lightning-input>
                </lightning-layout-item>
            </lightning-layout>
            
            <div class="slds-m-top_medium slds-align_absolute-center">
                <lightning-button variant="brand" label="Deploy" onclick={handleDeploy} disabled={isDeployButtonDisabled}></lightning-button>
            </div>
        </div>
        
        <!-- Status display section -->
        <template if:true={showStatus}>
            <div class="slds-m-around_medium">
                <div class="slds-box slds-theme_shade">
                    <h3 class="slds-text-heading_small">Deployment Status</h3>
                    <p>Status: {deploymentStatus}</p>
                    <template if:true={deploymentId}>
                        <lightning-formatted-url value={deploymentRecordUrl} label="View Deployment Record" target="_blank"></lightning-formatted-url>
                    </template>
                </div>
            </div>
        </template>
    </lightning-card>
</template>
```

#### JavaScript Controller (declarativeMetadataDeployer.js):
```javascript
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import queryMetadata from '@salesforce/apex/MetadataQueryController.queryMetadata';
import getMetadataTypes from '@salesforce/apex/MetadataQueryController.getMetadataTypes';
import createDeployment from '@salesforce/apex/DeploymentController.createDeployment';
import initiateDeployment from '@salesforce/apex/DeploymentController.initiateDeployment';
import getDeploymentStatus from '@salesforce/apex/DeploymentController.getDeploymentStatus';

export default class DeclarativeMetadataDeployer extends LightningElement {
    // Properties for search and filter
    @track searchTerm = '';
    @track selectedMetadataType = '';
    @track metadataTypeOptions = [];
    
    // Properties for datatable
    @track metadataResults = [];
    @track columns = [/* define columns */];
    @track selectedColumns = [/* define columns for selected components */];
    @track selectedRows = [];
    @track selectedComponents = [];
    
    // Properties for deployment configuration
    @track targetOrg = '';
    @track testLevel = 'NoTestRun';
    @track testLevelOptions = [
        { label: 'No Test Run', value: 'NoTestRun' },
        { label: 'Run Specified Tests', value: 'RunSpecifiedTests' },
        { label: 'Run Local Tests', value: 'RunLocalTests' },
        { label: 'Run All Tests In Org', value: 'RunAllTestsInOrg' }
    ];
    @track runTests = '';
    @track checkOnly = false;
    @track rollbackOnError = true;
    @track ignoreWarnings = false;
    @track userComments = '';
    
    // Properties for deployment status
    @track showStatus = false;
    @track deploymentId;
    @track deploymentStatus = '';
    @track deploymentRecordUrl = '';
    
    // Pagination properties
    @track hasMoreData = false;
    
    // Lifecycle hooks
    connectedCallback() {
        this.loadMetadataTypes();
    }
    
    // Methods to load metadata types
    loadMetadataTypes() {
        getMetadataTypes()
            .then(result => {
                this.metadataTypeOptions = result.map(type => {
                    return { label: type, value: type };
                });
            })
            .catch(error => {
                this.showToast('Error', 'Error loading metadata types: ' + error.body.message, 'error');
            });
    }
    
    // Methods for search and filter
    handleTypeChange(event) {
        this.selectedMetadataType = event.detail.value;
        this.searchMetadata();
    }
    
    handleSearchChange(event) {
        const searchValue = event.target.value;
        
        // Debounce search input
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.searchTerm = searchValue;
            this.searchMetadata();
        }, 300);
    }
    
    searchMetadata() {
        if (this.selectedMetadataType) {
            queryMetadata({ metadataType: this.selectedMetadataType, searchTerm: this.searchTerm })
                .then(result => {
                    this.metadataResults = result;
                })
                .catch(error => {
                    this.showToast('Error', 'Error searching metadata: ' + error.body.message, 'error');
                });
        }
    }
    
    // Methods for row selection
    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        this.updateSelectedComponents();
    }
    
    updateSelectedComponents() {
        // Update selected components based on selectedRows
        // Ensure selections persist across searches
    }
    
    handleRemoveSelection(event) {
        // Remove component from selected list
    }
    
    // Methods for deployment configuration
    handleTargetOrgChange(event) {
        this.targetOrg = event.target.value;
    }
    
    handleTestLevelChange(event) {
        this.testLevel = event.detail.value;
    }
    
    handleCheckOnlyChange(event) {
        this.checkOnly = event.target.checked;
    }
    
    handleRollbackChange(event) {
        this.rollbackOnError = event.target.checked;
    }
    
    handleCommentsChange(event) {
        this.userComments = event.target.value;
    }
    
    // Method for infinite scrolling
    loadMoreData() {
        // Implement logic for loading more data
    }
    
    // Methods for deployment
    handleDeploy() {
        if (!this.selectedComponents.length || !this.targetOrg) {
            this.showToast('Error', 'Please select at least one component and specify target org', 'error');
            return;
        }
        
        // Show spinner
        this.isLoading = true;
        
        // Create deployment record
        createDeployment({
            targetOrg: this.targetOrg,
            selections: this.selectedComponents,
            checkOnly: this.checkOnly,
            testLevel: this.testLevel,
            runTests: this.runTests,
            rollbackOnError: this.rollbackOnError,
            ignoreWarnings: this.ignoreWarnings,
            userComments: this.userComments
        })
            .then(deploymentId => {
                this.deploymentId = deploymentId;
                this.showStatus = true;
                this.deploymentStatus = 'Pending';
                this.deploymentRecordUrl = '/' + deploymentId;
                
                // Initiate deployment
                return initiateDeployment({ deploymentId: deploymentId });
            })
            .then(() => {
                this.showToast('Success', 'Deployment initiated successfully', 'success');
                
                // Start polling for status
                this.pollDeploymentStatus();
            })
            .catch(error => {
                this.showToast('Error', 'Error initiating deployment: ' + error.body.message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
    pollDeploymentStatus() {
        // Implement polling for deployment status updates
    }
    
    // Utility methods
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
    
    get isDeployButtonDisabled() {
        return !this.selectedComponents.length || !this.targetOrg;
    }
}
```

#### Configuration (declarativeMetadataDeployer.js-meta.xml):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>59.0</apiVersion>
    <isExposed>true</isExposed>
    <masterLabel>Declarative Metadata Deployer</masterLabel>
    <description>Component to search, select, and deploy metadata</description>
    <targets>
        <target>lightning__AppPage</target>
        <target>lightning__Tab</target>
    </targets>
</LightningComponentBundle>
```

## 4. External Deployment Engine (Middleware)

For the external middleware, you'll need to set up a Node.js application (likely on Heroku). Here's a simplified outline:

```javascript
// app.js - Main application file
const express = require('express');
const jwt = require('jsonwebtoken');
const jsforce = require('jsforce');
const fs = require('fs');
const path = require('path');
const bodyParser = require('body-parser');
const app = express();

app.use(bodyParser.json());

// Endpoint to receive deployment requests
app.post('/api/deploy', async (req, res) => {
    try {
        const { sourceOrgAlias, targetOrgAlias, components, packageXmlVersion, deployOptions } = req.body;
        
        // Authenticate to source org
        const sourceConn = await authenticateToSalesforceOrg(sourceOrgAlias);
        
        // Authenticate to target org
        const targetConn = await authenticateToSalesforceOrg(targetOrgAlias);
        
        // Build package.xml
        const packageXml = buildPackageXml(components, packageXmlVersion);
        
        // Retrieve metadata from source org
        const retrieveResult = await retrieveMetadata(sourceConn, packageXml);
        
        // Deploy to target org
        const deployResult = await deployMetadata(targetConn, retrieveResult.zipFile, deployOptions);
        
        // Send deployment ID back to caller
        res.json({
            success: true,
            deploymentId: deployResult.id
        });
        
        // Start monitoring deployment status
        monitorDeploymentStatus(targetConn, deployResult.id, req.body.callbackUrl);
    } catch (error) {
        console.error('Deployment error:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

// Helper functions for authentication, retrieval, deployment, etc.
```

## 5. Implementation Sequence

Here's the recommended sequence for implementing this solution:

1. **Create Custom Objects**:
   - Set up Deployment__c and Metadata_Selection__c objects with all required fields.
   - Create Master-Detail relationship between them.

2. **Develop Core Apex Classes**:
   - Implement ToolingAPIService for base Tooling API interaction.
   - Develop MetadataQueryController for metadata search functionality.
   - Create DeploymentController for handling deployment record creation.
   - Implement DeploymentCallbackEndpoint for receiving status updates.

3. **Build Lightning Web Component**:
   - Create the declarativeMetadataDeployer LWC with search, filter, and selection capabilities.
   - Implement datatable with infinite scrolling.
   - Add deployment configuration form and status display.

4. **Set Up External Deployment Engine**:
   - Create a Node.js application on Heroku.
   - Implement API endpoint for receiving deployment requests.
   - Set up JWT Bearer Flow authentication to Salesforce orgs.
   - Develop metadata retrieval and deployment logic.
   - Implement callback mechanism for status updates.

5. **Configure Security**:
   - Set up Named Credential in Salesforce for secure callouts to middleware.
   - Create Metadata_Deployer__c permission set for controlled access.
   - Configure Connected Apps in all relevant orgs for JWT Bearer Flow.

6. **Test & Refine**:
   - Unit test Apex classes with HttpCalloutMock.
   - Test LWC functionality with Jest.
   - Conduct integration testing across the entire flow.
   - Perform user acceptance testing with stakeholders.

7. **Package & Deploy**:
   - Create an unmanaged package containing all components.
   - Install in target orgs.
   - Configure post-installation settings like Named Credentials.
   - Assign permission set to relevant users.

## 6. Future Enhancements

Once the core functionality is working, consider these enhancements:

1. **Deployment History and Comprehensive Audit Logs**:
   - Add a dedicated history view for past deployments.
   - Enhance logging with component-level success/failure details.

2. **Rollback/Undo Functionality**:
   - Implement backup storage of retrieved metadata.
   - Add rollback button to revert changes from failed deployments.

3. **Advanced Filtering and Search**:
   - Add filtering by metadata attributes (status, version, etc.).
   - Implement full-text search within metadata content.

4. **Integration with Commercial DevOps Tools**:
   - Consider integration points with Copado, Gearset, or Salesforce DevOps Center.
