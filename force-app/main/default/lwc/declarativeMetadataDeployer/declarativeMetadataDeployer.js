import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import queryMetadata from '@salesforce/apex/MetadataQueryController.queryMetadata';
import getMetadataTypes from '@salesforce/apex/MetadataQueryController.getMetadataTypes';
import executeToolingQuery from '@salesforce/apex/MetadataQueryController.executeToolingQuery';
import prepareDeployment from '@salesforce/apex/MetadataDeploymentController.prepareDeployment';
import deployComponents from '@salesforce/apex/MetadataDeploymentController.deployComponents';

export default class DeclarativeMetadataDeployer extends LightningElement {
    // Properties for search and filter
    @track searchTerm = '';
    @track selectedMetadataType = '';
    @track metadataTypeOptions = [];
    @track hasSearched = false;
    @track isLoading = false;
    
    // Properties for datatable
    @track metadataResults = [];
    @track columns = [
        { label: 'Name', fieldName: 'name', type: 'text', sortable: true },
        { label: 'API Name', fieldName: 'apiName', type: 'text', sortable: true },
        { label: 'Type', fieldName: 'type', type: 'text', sortable: true },
        { label: 'Last Modified', fieldName: 'formattedDate', type: 'text', sortable: true }
    ];
    @track selectedColumns = [
        { label: 'Name', fieldName: 'name', type: 'text' },
        { label: 'API Name', fieldName: 'apiName', type: 'text' },
        { label: 'Type', fieldName: 'type', type: 'text' },
        { 
            label: 'Comment', 
            fieldName: 'deploymentComment', 
            type: 'text',
            editable: true,
            wrapText: true
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Edit Comment', name: 'edit_comment' },
                    { label: 'Remove', name: 'remove' }
                ]
            }
        }
    ];
    @track selectedRows = [];
    @track selectedComponents = [];
    
    // Properties for deployment configuration
    @track deploymentName = '';
    @track deploymentComments = '';
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

    // Property for tracking if a component comment is being edited
    @track editingComment = false;
    @track currentEditComponentId = null;
    @track currentEditCommentValue = '';
    
    // Initialize queryInput and queryResults properties
    @track queryInput = '';
    @track queryResults = [];
    @track error = undefined;
    
    // Lifecycle hooks
    connectedCallback() {
        this.loadMetadataTypes();
    }
    
    // Methods to load metadata types
    loadMetadataTypes() {
        this.isLoading = true;
        getMetadataTypes()
            .then(result => {
                this.metadataTypeOptions = result.map(type => {
                    return { label: type, value: type };
                });
                this.metadataTypeOptions.sort((a, b) => a.label.localeCompare(b.label));
            })
            .catch(error => {
                this.showToast('Error', 'Error loading metadata types: ' + this.extractErrorMessage(error), 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
    // Methods for search and filter
    handleTypeChange(event) {
        this.selectedMetadataType = event.detail.value;
        this.metadataResults = [];
        this.hasSearched = false;
        this.searchTerm = '';
        this.selectedRows = []; // Clear selected rows when type changes
    }
    
    handleSearchChange(event) {
        const searchValue = event.target.value;
        
        // Debounce search input
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.searchTerm = searchValue;
            this.searchMetadata();
        }, 500);
    }
    
    searchMetadata() {
        if (!this.selectedMetadataType) {
            return;
        }
        
        this.isLoading = true;
        this.hasSearched = true;
        
        queryMetadata({ 
            metadataType: this.selectedMetadataType, 
            searchTerm: this.searchTerm 
        })
            .then(result => {
                if (Array.isArray(result)) {
                    // Process results to ensure they have unique IDs for the datatable
                    this.metadataResults = result.map(item => {
                        return {
                            ...item,
                            id: item.id || (item.apiName + '_' + item.type) // Ensure we have a unique ID
                        };
                    });
                    
                    // Mark items that are already selected
                    if (this.selectedComponents && this.selectedComponents.length > 0) {
                        const selectedIds = new Set(this.selectedComponents.map(item => item.id));
                        this.selectedRows = this.metadataResults
                            .filter(item => selectedIds.has(item.id))
                            .map(item => item.id);
                    }
                } else {
                    this.metadataResults = [];
                }
            })
            .catch(error => {
                this.showToast('Error', 'Error searching metadata: ' + this.extractErrorMessage(error), 'error');
                this.metadataResults = [];
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
    // Methods for row selection
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows || [];
        const currentSelections = [...(this.selectedComponents || [])];
        
        // Find newly selected items
        for (const row of selectedRows) {
            if (!currentSelections.some(item => item.id === row.id)) {
                // Initialize a deployment comment for the new component
                const newComponent = {...row};
                newComponent.deploymentComment = '';
                currentSelections.push(newComponent);
            }
        }
        
        // Find unselected items
        const selectedIds = new Set(selectedRows.map(row => row.id));
        const resultsIds = new Set((this.metadataResults || []).map(item => item.id));
        
        // Only remove items that are in the current result set and were unselected
        this.selectedComponents = currentSelections.filter(item => 
            !resultsIds.has(item.id) || selectedIds.has(item.id)
        );
    }
    
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        
        if (action.name === 'remove') {
            this.selectedComponents = this.selectedComponents.filter(item => item.id !== row.id);
            this.selectedRows = this.selectedRows.filter(id => id !== row.id);
        } else if (action.name === 'edit_comment') {
            // Open a modal to edit the comment
            this.editingComment = true;
            this.currentEditComponentId = row.id;
            this.currentEditCommentValue = row.deploymentComment || '';
        }
    }

    // Handle comment changes in the selected components table
    handleCellChange(event) {
        const draftValues = event.detail.draftValues;
        let componentsToUpdate = [...this.selectedComponents];
        
        draftValues.forEach(draft => {
            const index = componentsToUpdate.findIndex(item => item.id === draft.id);
            if (index !== -1 && draft.deploymentComment !== undefined) {
                componentsToUpdate[index].deploymentComment = draft.deploymentComment;
            }
        });
        
        this.selectedComponents = componentsToUpdate;
    }
    
    // Methods for comment editing modal
    handleCommentChange(event) {
        this.currentEditCommentValue = event.target.value;
    }
    
    saveComment() {
        if (this.currentEditComponentId) {
            const componentsToUpdate = [...this.selectedComponents];
            const index = componentsToUpdate.findIndex(item => item.id === this.currentEditComponentId);
            
            if (index !== -1) {
                componentsToUpdate[index].deploymentComment = this.currentEditCommentValue;
                this.selectedComponents = componentsToUpdate;
            }
        }
        
        this.closeCommentModal();
    }
    
    closeCommentModal() {
        this.editingComment = false;
        this.currentEditComponentId = null;
        this.currentEditCommentValue = '';
    }
    
    // Handle deployment
    handleDeploy() {
        if (!this.selectedComponents || !this.selectedComponents.length || !this.deploymentName) {
            this.showToast('Error', 'Please select components and provide a deployment name', 'error');
            return;
        }
        
        this.isLoading = true;
        
        // Prepare deployment options
        const deploymentOptions = {
            testLevel: this.testLevel,
            runTests: this.runTests,
            checkOnly: this.checkOnly,
            rollbackOnError: this.rollbackOnError,
            ignoreWarnings: this.ignoreWarnings
        };
        
        // Add the overall deployment comment to each component that doesn't have one
        const componentsToDeploy = (this.selectedComponents || []).map(comp => {
            if (!comp.deploymentComment && this.deploymentComments) {
                comp.deploymentComment = this.deploymentComments;
            }
            return comp;
        });
        
        // Call the backend to prepare and deploy
        prepareDeployment({ components: componentsToDeploy })
            .then(preparedComponents => {
                return deployComponents({ 
                    deploymentName: this.deploymentName, 
                    components: preparedComponents, 
                    deploymentOptions: deploymentOptions 
                });
            })
            .then(deploymentId => {
                this.showToast('Success', `Deployment initiated with ID: ${deploymentId}`, 'success');
            })
            .catch(error => {
                this.showToast('Error', 'Error deploying components: ' + this.extractErrorMessage(error), 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
    // Methods for Tooling API query
    handleQueryChange(event) {
        this.queryInput = event.target.value;
    }

    async executeQuery() {
        this.isLoading = true;
        this.error = undefined;
        
        try {
            const response = await executeToolingQuery({ query: this.queryInput });
            this.queryResults = JSON.parse(response);
            
            this.showToast('Success', 'Query executed successfully', 'success');
        } catch (error) {
            console.error('Error executing query:', error);
            this.error = error.body?.message || error.statusText || 'Unknown error';
            this.showToast('Error', this.error, 'error');
            this.queryResults = [];
        } finally {
            this.isLoading = false;
        }
    }

    // Additional event handler methods for the UI
    handleDeploymentNameChange(event) {
        this.deploymentName = event.target.value;
    }
    
    handleTestLevelChange(event) {
        this.testLevel = event.target.value;
    }
    
    handleDeploymentCommentsChange(event) {
        this.deploymentComments = event.target.value;
    }
    
    handleCheckOnlyChange(event) {
        this.checkOnly = event.target.checked;
    }
    
    handleRollbackChange(event) {
        this.rollbackOnError = event.target.checked;
    }
    
    handleIgnoreWarningsChange(event) {
        this.ignoreWarnings = event.target.checked;
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
    
    extractErrorMessage(error) {
        let message = 'Unknown error';
        if (typeof error === 'string') {
            message = error;
        } else if (error.body && error.body.message) {
            message = error.body.message;
        } else if (error.message) {
            message = error.message;
        }
        return message;
    }
    
    // Getters for computed properties
    get isDeployButtonDisabled() {
        return !this.selectedComponents || !this.selectedComponents.length || !this.deploymentName;
    }
    
    get isSearchDisabled() {
        return !this.selectedMetadataType;
    }
    
    // Method to handle row selection in the search results table
    handleMetadataRowSelection(event) {
        const selectedRows = event.detail.selectedRows || [];
        this.addToDeployment(selectedRows);
    }
    
    // Method to add selected components to the deployment
    addToDeployment(componentsToAdd) {
        if (!Array.isArray(componentsToAdd) || componentsToAdd.length === 0) {
            return;
        }
        
        // Initialize selectedComponents if it doesn't exist
        if (!this.selectedComponents) {
            this.selectedComponents = [];
        }
        
        const currentSelections = [...this.selectedComponents];
        
        // Add newly selected components
        for (const component of componentsToAdd) {
            if (!currentSelections.some(item => item.id === component.id)) {
                const deploymentComponent = {...component};
                deploymentComponent.deploymentComment = ''; // Initialize comment
                currentSelections.push(deploymentComponent);
            }
        }
        
        this.selectedComponents = currentSelections;
    }
}
