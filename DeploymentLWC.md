@Erin Allchinhad an idea surrounding a flow/lwc to easily be able to enter components into the “Deployment” object internally within 8squad Salesforce, @James Perram identified the types of data which would be useful as a part of this process. @James Perram had an idea as below to use apex to query metadata internally using the Salesforce Tooling AI and syncing it back to the component per environment.

The benifit is this could be used and installed for all environments through the use of a unmanaged package too, this way all CoE members have an easy way to be able to query metadata in a particular environment

Proof of Concept (POC) Summary: Declarative Metadata Deployer in LWC
🔍 Objective
Create a user-friendly Lightning Web Component (LWC) that allows users to:

Search for metadata components (Apex Classes, Flows, Objects, etc.)

Select and store them via a custom object

Trigger a deployment to another Salesforce org (or middleware) with a single click

Bypass native Change Set limitations by using Metadata API or SFDX-based deployment

🧱 High-Level Architecture


[Salesforce Org A (LWC UI)]
   ↳ Apex Controller
       ↳ Tooling API: Query metadata types
       ↳ Save user selections to custom object
   ↳ "Deploy" Button
       ↳ Sends selected metadata to middleware or Org B via Named Credential/API
[Middleware or Org B]
   ↳ Accepts metadata list (e.g., via REST API)
   ↳ Retrieves metadata using SFDX or Metadata API
   ↳ Deploys to target org
   ↳ Returns deployment status back to Org A
💡 Key Features
Feature

Status

Details

Search Metadata

✅

Use Tooling API in Apex to query components

Select Components

✅

Show in LWC datatable, allow multi-select

Store Selections

✅

Save to MetadataSelection__c custom object

Create Change Set

❌

Not possible via API

Trigger Deployment

✅

Use Metadata API or SFDX via middleware or direct API call

🛠 Tech Stack
Frontend: LWC (search, select, deploy UI)

Backend (Salesforce): Apex controller using Tooling API

Auth/Callout: Named Credential (JWT or OAuth)

Deployment Engine: Middleware (Node.js/Heroku) or Org B with exposed API

Optional: Store deployment logs in MetadataDeployment__c object

🧾 Sample API Payload (to send to middleware/Org B)


{
  "sourceOrgAlias": "dev-org",
  "targetOrgAlias": "prod-org",
  "components": [
    { "type": "ApexClass", "name": "MyTriggerHandler" },
    { "type": "Flow", "name": "OnboardingFlow" }
  ],
  "packageXmlVersion": "59.0",
  "deployOptions": {
    "checkOnly": false,
    "runTests": ["TriggerHandlerTest"]
  }
}
🔐 Security
Use Named Credentials in Salesforce

Authenticate with JWT or OAuth between Org A and Org B or middleware

Add permission set: Metadata_Deployer__c to restrict access

🎯 Business Value
Declarative, low-code DevOps tool

Removes manual Change Set frustrations

Empowers Admins and Junior Devs to contribute to deployments

Supports multi-org pipelines, audit logs, and rollback potential

📦 Optional Add-Ons
Deployment history tab (log success/failures)

Rollback/Undo functionality (store backup ZIP)

Component type filters (flows only, apex only, etc.)

 

Comprehensive Engineering and Solution Design: Declarative Metadata Deployer for Salesforce
 

 

Executive Summary
 

This document outlines the engineering and solution design for the "Declarative Metadata Deployer" Salesforce application, a tool aimed at streamlining metadata deployments within 8squad's Salesforce environments. By leveraging a Lightning Web Component (LWC) for intuitive user interaction, Apex for metadata discovery via the Tooling API, and a robust external middleware for Metadata API/SFDX-based deployments, this solution bypasses traditional Change Set limitations. It provides a declarative, low-code DevOps capability, empowering Admins and Junior Devs while ensuring secure, scalable, and auditable deployment processes across multi-org pipelines. The design emphasizes robust error handling, performance optimization for large datasets, and a clear path for future enhancements, all packaged for internal distribution.

 

1. Introduction
 

 

1.1. Project Vision and Objectives
 

The overarching vision for the Declarative Metadata Deployer is to empower 8squad Salesforce users, including members of the Center of Excellence (CoE), administrators, and junior developers, with a simplified, declarative tool for managing metadata deployments. This initiative aims to move beyond the inherent limitations and manual overhead associated with Salesforce Change Sets.

The project's key objectives are:

User-Friendly Interface: To develop an intuitive Lightning Web Component (LWC) that provides a straightforward mechanism for users to search for and select various metadata components, such as Apex Classes, Flows, and Custom Objects.

Efficient Metadata Discovery: To implement Apex logic that effectively utilizes the Salesforce Tooling API. This will enable dynamic querying and presentation of diverse metadata types from the current Salesforce environment, facilitating easy identification and selection of components for deployment.

Streamlined Deployment: To establish a process for one-click deployment of selected metadata to designated target Salesforce environments (or via middleware). This objective specifically aims to bypass native Change Set limitations by employing the more flexible and powerful Metadata API or SFDX-based deployment mechanisms.

Internal Tracking and Auditability: To ensure that all user selections and critical deployment metadata are systematically stored within a custom "Deployment" object in Salesforce. This data will serve as a comprehensive historical record, crucial for auditing, troubleshooting, and compliance.

Scalability and Reusability: To design the solution for seamless distribution as an unmanaged package. This approach will allow for easy installation across all 8squad environments, promoting a consistent and accessible DevOps practice throughout the organization.

 

1.2. Business Value and Strategic Impact
 

This solution is poised to deliver substantial business value by transforming a traditionally complex, time-consuming, and manual metadata deployment process into an efficient, user-friendly operation.

Declarative, Low-Code DevOps Tool: The Declarative Metadata Deployer will serve as a declarative, low-code DevOps tool, significantly reducing reliance on complex command-line interfaces (such as SFDX CLI) or the often cumbersome Change Set process. This democratization of deployment capabilities makes the process accessible to a wider range of users, including Salesforce Administrators and Junior Developers, fostering a more inclusive and efficient DevOps culture within 8squad.

Improved Efficiency and Reduced Frustrations: A primary benefit of this tool is its direct addressal of the frustrations associated with manual Change Sets, which include tedious component selection, intricate dependency tracking, and the lack of robust API support for automation. By automating these steps, the solution will dramatically improve operational efficiency, minimize human error, and accelerate release cycles for Salesforce changes.

Empowerment of Admins and Junior Devs: By providing a guided, user-interface-driven approach, the tool enables less technical users to contribute effectively to the deployment process. This empowerment frees up senior developers to focus on more complex architectural challenges and advanced development tasks, optimizing resource allocation within the team.

Foundation for Multi-Org Pipelines and Enhanced Control: The architectural design, particularly the reliance on an external middleware or a dedicated deployment Salesforce organization, inherently supports deployments across various target environments (e.g., from development to quality assurance, or from user acceptance testing to production). This lays a robust foundation for establishing more sophisticated Continuous Integration/Continuous Delivery (CI/CD) pipelines in the future. Furthermore, the systematic logging of deployment details to a custom object creates an invaluable auditable history. This data is indispensable for troubleshooting, ensuring compliance with internal and external regulations, and forms the critical basis for implementing future rollback capabilities, thereby significantly enhancing operational resilience.

 

1.3. Target User Persona and Key Use Cases
 

The Declarative Metadata Deployer is specifically designed for a core set of users within 8squad.

Target User Persona: The primary users of this tool are Salesforce Administrators, Junior Developers, and members of the Center of Excellence (CoE) within 8squad. These individuals often require a simplified, intuitive tool to manage metadata changes without needing deep command-line expertise or relying on complex, full-fledged external CI/CD platforms for routine or ad-hoc deployments.

Key Use Cases:

Quick Fix Deployment: An administrator identifies a critical bug in a Flow or an Apex Class within a UAT (User Acceptance Testing) environment. The tool enables them to quickly select and deploy a validated fix from a development organization, minimizing downtime and impact.

Small-Scale Feature Rollout: A junior developer completes a minor enhancement, such as creating a new custom field or updating a validation rule. The tool provides an easy, guided process to deploy these changes to a Quality Assurance (QA) environment for testing.

Environment Synchronization: A CoE member needs to ensure that a specific Apex Class, Custom Object definition, or other metadata component is consistent across multiple sandbox environments. The tool facilitates this by allowing them to query and deploy the component to various target organizations.

Ad-hoc Metadata Retrieval and Inspection: A user requires a quick way to locate and inspect the definition or properties of a specific Apex Class or Custom Object within an environment for analysis, documentation, or troubleshooting purposes.

 

2. Solution Architecture Overview
 

 

2.1. High-Level Architecture Diagram
 

The system is engineered with a clear separation of concerns, distributing functionality across distinct layers to ensure scalability, maintainability, and security.

Salesforce Org A (Source Org): This serves as the user-facing application environment. It hosts the Lightning Web Component (LWC) user interface, the custom objects (Deployment__c and Metadata_Selection__c) for tracking, and the Apex controllers. The Apex controllers are responsible for querying metadata from the current org using the Tooling API and orchestrating external callouts for deployments.

External Deployment Engine (Middleware): This component is crucial for executing the actual metadata deployment. It is designed as a dedicated external service, ideally implemented as a Node.js application hosted on a platform like Heroku. This engine receives deployment requests from Salesforce Org A, authenticates to the specified target Salesforce org, retrieves the necessary metadata (if not provided in the payload), constructs the package.xml manifest, and executes the deployment using either the Salesforce Metadata API or SFDX CLI commands. It also handles returning deployment status back to Salesforce Org A.

Salesforce Org B (Target Org): This represents the destination Salesforce environment(s) where the metadata changes are applied. This could be any Salesforce org (e.g., a sandbox, a production environment) that is accessible and authenticated by the External Deployment Engine.

Flow of Operations:

User Interaction: A user accesses the LWC within Salesforce Org A.

Metadata Discovery: The LWC initiates a call to an Apex Controller in Org A. The Apex Controller then utilizes the Tooling API to query metadata information from Org A, presenting a list of components for user selection.

Selection Persistence: The user selects desired metadata components. The Apex Controller saves these selections, along with deployment parameters, to the Deployment__c and Metadata_Selection__c custom objects within Org A.

Deployment Initiation: Upon user confirmation, the "Deploy" button triggers the Apex Controller. The controller initiates an asynchronous callout, leveraging a Named Credential, to the External Deployment Engine.

Deployment Execution: The External Deployment Engine receives the deployment request. It then authenticates to the specified Source Org (for retrieval of component content) and Target Org (for deployment). It constructs the necessary deployment package (e.g., a package.xml and the actual metadata files), and executes the deployment using the Metadata API or SFDX CLI.

Status Reporting: The External Deployment Engine continuously monitors the deployment status via the Metadata API. Once the deployment process is complete, it sends detailed status updates (including success, failure, and logs) back to Salesforce Org A. This callback can be implemented via a REST API call to an endpoint exposed by Org A or through Salesforce Platform Events.

Status Update in Org A: An Apex controller in Org A receives the status callback. It then updates the Deployment__c record and its associated Metadata_Selection__c records with the latest status, error messages, and detailed logs, ensuring an auditable history.

TABLE: High-Level Architecture Components and Responsibilities

Component

Primary Responsibilities

Key Technologies

Salesforce Org A (LWC UI)

User Interface for search, selection, deployment configuration.

Lightning Web Components (LWC), HTML, JavaScript

Salesforce Org A (Apex Controller)

Metadata discovery (Tooling API), data persistence (Deployment__c, Metadata_Selection__c), orchestrate external callouts.

Apex, Tooling API (REST), Named Credentials, Queueable Apex

External Deployment Engine

Receive deployment requests, authenticate to target orgs, retrieve metadata content, construct package.xml, execute Metadata API deploy() or SFDX commands, monitor deployment status, send status callbacks.

Node.js (or similar), Heroku, Salesforce Metadata API, SFDX CLI, OAuth 2.0 JWT Bearer Flow, REST API

Salesforce Org B (Target Org)

Receive and apply metadata changes.

Salesforce Platform

Export to Sheets

 

2.2. Architectural Principles and Design Choices
 

The design of the Declarative Metadata Deployer is guided by several core architectural principles to ensure a robust, scalable, and maintainable solution.

Separation of Concerns: A fundamental principle applied here is the clear separation of responsibilities. Salesforce Org A is primarily dedicated to the user interface and the orchestration of deployment requests, while the External Deployment Engine is solely responsible for the computationally intensive and API-heavy tasks of metadata retrieval and deployment. This modular approach is critical for adhering to Salesforce governor limits, optimizing performance, and enabling independent scaling and maintenance of each component.

Asynchronous Processing: All long-running operations, particularly the initiation of deployments and the subsequent handling of status updates, are designed to be asynchronous. This design choice is paramount for preventing the user interface from freezing, ensuring a smooth and responsive user experience, and allowing the Salesforce platform to efficiently manage its shared resources by processing these tasks in the background.

Security by Design: Security is integrated into the solution from its inception. All outbound calls from Salesforce Org A to the External Deployment Engine will leverage Salesforce's secure Named Credentials, which centralize authentication details and enhance security through encryption. For server-to-server authentication between the External Deployment Engine and target Salesforce organizations, OAuth 2.0 JWT Bearer Flow is employed, providing a robust and automated authentication mechanism. Within Salesforce, granular permission sets will strictly control user access to the application's functionalities.

Scalability and Performance: To ensure the application performs optimally even when dealing with large volumes of metadata, various strategies are incorporated. These include server-side pagination and lazy loading within the LWC for efficient data display. Additionally, the design meticulously addresses the nuances and limitations of Salesforce APIs, such as the Tooling API, to optimize query performance and data handling.

Robustness and Resiliency: The solution is designed to be resilient to failures. Comprehensive error handling mechanisms, detailed logging, and intelligent retry strategies are implemented at both the Apex controller level and within the External Deployment Engine. This ensures that the system can gracefully manage transient failures, provide clear feedback on persistent issues, and maintain operational stability.

 

2.3. Component Responsibilities and Interactions
 

Each major component within the architecture has distinct responsibilities and defined interaction patterns.

Lightning Web Component (LWC): The LWC serves as the primary user interface. Its responsibilities include capturing user input for metadata search criteria, displaying search results in an interactive and paginated datatable, managing the multi-selection of desired components, collecting deployment configuration options (such as the target organization, descriptive comments, and test settings), initiating deployment requests by invoking Apex methods, and providing real-time visual feedback on the deployment's progress and final status to the user.

Apex Controller (in Salesforce Org A): This layer acts as the intermediary and orchestrator within Salesforce. Its key responsibilities include querying metadata component lists from the current Salesforce organization by interacting with the Tooling API. It also handles the persistence of user-selected components and all associated deployment details into the custom Deployment__c and Metadata_Selection__c objects. Crucially, it initiates asynchronous HTTP callouts to the External Deployment Engine for actual deployment execution and processes the incoming status updates or callbacks from the engine.

External Deployment Engine: This external service is tasked with the heavy lifting of metadata operations. It receives deployment requests from Salesforce Org A, securely authenticates to the specified source and target Salesforce organizations, retrieves the necessary metadata components (e.g., Apex Class bodies, Flow definitions) from the source environment, constructs the appropriate package.xml manifest, and executes the Metadata API deploy() call (or equivalent SFDX commands) to the target organization. Furthermore, it continuously monitors the deployment status and, upon completion or failure, sends a detailed status report back to Salesforce Org A.

Custom Objects (Deployment__c, Metadata_Selection__c): These custom objects form the internal data model for the application within Salesforce Org A. The Deployment__c object is designed to track each individual deployment request, recording its overall status, configuration parameters, and a comprehensive log of the deployment process. The Metadata_Selection__c object stores the granular details of each individual metadata component chosen for a particular deployment, providing a precise record of what was included and serving as a vital part of the audit trail.

 

3. Detailed Design: Salesforce Org A (LWC UI & Apex Controller)
 

 

3.1. Custom Objects Design
 

The design of custom objects within Salesforce Org A is fundamental to tracking deployment requests and their associated metadata components.

 

3.1.1. Deployment__c Object Schema
 

The Deployment__c object is designed to serve as the central record for each initiated metadata deployment. It captures the configuration, current status, and a comprehensive log of the deployment lifecycle. This object is indispensable for auditing, troubleshooting, and providing transparency into all deployment activities.

Name (Auto-Number): This field will automatically generate a unique identifier for each deployment record (e.g., "DEP-00001"). This auto-numbering ensures uniqueness and provides a concise, easily referenceable identifier for each deployment.

Status__c (Picklist): This field tracks the current state of the deployment process. Its values are meticulously aligned with the DeployResult.status values provided by the Metadata API to ensure consistent and clear status reporting:

Pending: The deployment request has been received and is awaiting processing.

InProgress: The deployment is actively being executed by the External Deployment Engine.

Succeeded: All components within the deployment package were deployed successfully.

SucceededPartial: Some components were deployed successfully, while others encountered errors.

Failed: The entire deployment process encountered a critical error and failed.

Canceling: A request to cancel the deployment has been initiated.

Canceled: The deployment process has been successfully stopped.

Source_Org_Alias__c (Text): This field stores a user-friendly alias or identifier for the Salesforce organization from which the metadata components were originally selected for retrieval. This helps in understanding the origin of the deployed changes.

Target_Org_Alias__c (Text): This field stores a user-friendly alias or identifier for the Salesforce organization to which the metadata components are being deployed. This clearly identifies the destination environment.

Deployment_ID__c (Text): This critical field stores the unique ID returned by the Metadata API deploy() call (AsyncResult.id or DeployResult.id). This ID is essential for the External Deployment Engine to poll the deployment status via the Metadata API and for linking internal Salesforce records to external deployment processes.

User_Comments__c (Long Text Area): This field allows the user to enter descriptive comments or notes about the purpose, context, or rationale behind the deployment. This provides crucial human-readable context, which is invaluable for auditing, post-deployment review, and team collaboration.

Deployment_Log__c (Rich Text Area): A comprehensive field designed to store detailed, time-stamped logs of the entire deployment process. This includes messages received from the Metadata API (such as success confirmations, warnings, or specific error details), any retry attempts made, and other relevant operational information. Using a Rich Text Area allows for better formatting and readability of these log entries, making troubleshooting more efficient.

Check_Only__c (Checkbox): This field directly corresponds to the checkOnly parameter in DeployOptions. When true, the deployment performs a validation-only check of components without actually saving them in the target org. This is useful for verifying deployment readiness without committing changes.

Run_Tests__c (Text Area): This field will store a comma-separated list of specific Apex test class names that should be executed during the deployment. It maps directly to the runTests parameter in DeployOptions, allowing for targeted testing.

Test_Level__c (Picklist): This field defines the level of Apex tests to be executed during the deployment. The available values are:

NoTestRun: No tests are run (applicable only to development environments like sandboxes).

RunSpecifiedTests: Only the tests explicitly listed in Run_Tests__c are executed.

RunLocalTests: All tests in the target org are run, excluding those from installed managed and unlocked packages (default for production deployments with Apex).

RunAllTestsInOrg: All tests in the target org, including those from managed packages, are executed.

Rollback_On_Error__c (Checkbox): This field corresponds to the rollbackOnError parameter in DeployOptions. If true, any failure during the deployment process will cause a complete rollback, ensuring that no partial changes are committed. This parameter is critical and must be set to true when deploying to production organizations.

Ignore_Warnings__c (Checkbox): This field maps to the ignoreWarnings parameter in DeployOptions. If true, the deployment process will continue and complete successfully even if warnings are generated during the deployment. If false, warnings will cause the deployment to fail by default.

CreatedDate (System Field): Automatically populated timestamp indicating when the deployment record was initially created.

LastModifiedDate (System Field): Automatically populated timestamp indicating the last time the deployment record was modified.

CreatedById (System Field): A lookup field to the User record of the individual who initiated the deployment.

LastModifiedById (System Field): A lookup field to the User record of the individual who last modified the deployment record.

 

3.1.2. Metadata_Selection__c Object Schema
 

The Metadata_Selection__c object is designed to store the individual metadata components that a user has selected for a specific deployment request. This object provides the granular detail necessary to understand precisely what was intended to be deployed as part of a larger deployment operation.

Name (Text): This field stores the human-readable name of the metadata component (e.g., "MyTriggerHandler" for an Apex Class, "OnboardingFlow" for a Flow).

Type__c (Picklist): This field specifies the metadata type of the component (e.g., ApexClass, Flow, CustomObject). Using a picklist ensures data consistency and facilitates categorization and processing of different component types.

API_Name__c (Text): This field stores the API name of the component, which is the programmatic name used for retrieval and deployment via Salesforce APIs. For example, for an Apex Class named "MyClass", the API Name would typically be "MyClass".

Deployment__c (Master-Detail to Deployment__c): This is a critical relationship field that links each individual selected metadata component directly to its parent Deployment__c record. This ensures that every selected component is explicitly associated with a specific deployment request.

Source_Org_Component_ID__c (Text): This field stores the unique ID of the component as it was retrieved from the Tooling API in the source organization. This ID can be valuable for debugging, cross-referencing, or future direct retrieval of the component from the source.

Component_Detail__c (Long Text Area - Optional): This field can optionally store a small snippet or key attributes of the metadata body (e.g., the first few lines of an Apex Class, or key properties of a Flow). It is important to note that this field is not intended to store the full metadata body due to potential size limitations and the specific Tooling API query limitations on the Body field for multiple records. Its purpose is to provide a brief, high-level overview or summary.

 

3.1.3. Relationships and Data Model
 

The core of the data model relies on a well-defined relationship between Deployment__c and Metadata_Selection__c.

Deployment__c (Parent) to Metadata_Selection__c (Child): A Master-Detail relationship is the recommended and most appropriate choice for connecting these two custom objects. This design decision is based on the inherent dependency of Metadata_Selection__c records on a specific Deployment__c request.

If a Deployment__c record is deleted (for instance, during cleanup of old deployment history or if a deployment request is cancelled before execution), its associated Metadata_Selection__c records should also be automatically deleted. The Master-Detail relationship provides this cascading delete behavior, which is crucial for maintaining data integrity and preventing orphaned records in the system.

Furthermore, child records in a Master-Detail relationship automatically inherit the security settings and permissions from their master record. This simplifies access control for Metadata_Selection__c records, as their visibility and editability are directly governed by the permissions on the parent Deployment__c record, aligning with the principle of least privilege and reducing administrative overhead. This tight coupling ensures that selected components are always in the context of a specific deployment.

TABLE: Custom Object Field Definitions

This table provides a clear, structured, and codable schema for the custom objects (Deployment__c and Metadata_Selection__c). This level of detail is essential for an AI agent to accurately generate the Salesforce object metadata (e.g., .object-meta.xml files) and for developers to fully understand the underlying data model. It ensures that all explicit and implicit requirements for tracking deployment information are comprehensively met.

Object Name

Field Name

Data Type

Description

API Name

Required

Notes

Deployment__c

Name

Auto-Number

Unique identifier for the deployment.

Name

Yes

Auto-generated (e.g., DEP-{0000})

Deployment__c

Status__c

Picklist

Current status of the deployment.

Status__c

Yes

Values: Pending, InProgress, Succeeded, SucceededPartial, Failed, Canceling, Canceled

Deployment__c

Source_Org_Alias__c

Text

Alias of the Salesforce org from which metadata was selected.

Source_Org_Alias__c

Yes

 

Deployment__c

Target_Org_Alias__c

Text

Alias of the Salesforce org to which metadata is deployed.

Target_Org_Alias__c

Yes

 

Deployment__c

Deployment_ID__c

Text(255)

Salesforce Metadata API deployment ID.

Deployment_ID__c

No

Populated by External Deployment Engine's callback

Deployment__c

User_Comments__c

Long Text Area

User-entered comments for the deployment.

User_Comments__c

No

 

Deployment__c

Deployment_Log__c

Rich Text Area

Detailed log of the deployment process.

Deployment_Log__c

No

Stores success/failure messages, errors, timestamps

Deployment__c

Check_Only__c

Checkbox

Perform validation only.

Check_Only__c

No

Maps to DeployOptions.checkOnly

Deployment__c

Run_Tests__c

Text Area

Comma-separated list of Apex test classes to run.

Run_Tests__c

No

Maps to DeployOptions.runTests

Deployment__c

Test_Level__c

Picklist

Level of Apex tests to execute.

Test_Level__c

No

Values: NoTestRun, RunSpecifiedTests, RunLocalTests, RunAllTestsInOrg

Deployment__c

Rollback_On_Error__c

Checkbox

Rollback entire deployment on any error.

Rollback_On_Error__c

No

Maps to DeployOptions.rollbackOnError

Deployment__c

Ignore_Warnings__c

Checkbox

Continue deployment even if warnings occur.

Ignore_Warnings__c

No

Maps to DeployOptions.ignoreWarnings

Deployment__c

CreatedDate

DateTime

System field: Date/time record created.

CreatedDate

Yes

System-generated

Deployment__c

LastModifiedDate

DateTime

System field: Date/time record last modified.

LastModifiedDate

Yes

System-generated

Deployment__c

CreatedById

Lookup(User)

System field: User who created the record.

CreatedById

Yes

System-generated

Deployment__c

LastModifiedById

Lookup(User)

System field: User who last modified the record.

LastModifiedById

Yes

System-generated

Metadata_Selection__c

Name

Text

Name of the metadata component.

Name

Yes

 

Metadata_Selection__c

Type__c

Picklist

Type of metadata component.

Type__c

Yes

Values: ApexClass, Flow, CustomObject, etc.

Metadata_Selection__c

API_Name__c

Text(255)

API name of the component.

API_Name__c

Yes

 

Metadata_Selection__c

Deployment__c

Master-Detail

Master-Detail relationship to Deployment__c.

Deployment__c

Yes

Cascading delete, security inheritance

Metadata_Selection__c

Source_Org_Component_ID__c

Text(18)

ID of the component in the source org (from Tooling API).

Source_Org_Component_ID__c

No

 

Metadata_Selection__c

Component_Detail__c

Long Text Area

Optional snippet/key attributes of metadata body.

Component_Detail__c

No

Not full metadata body due to Tooling API limitations

Export to Sheets

 

3.2. Lightning Web Component (LWC) Design
 

The Lightning Web Component (LWC) serves as the primary user interface, providing an intuitive and responsive experience for interacting with the Declarative Metadata Deployer.

 

3.2.1. User Interface Flow and Experience
 

A single LWC, named declarativeMetadataDeployer, will encapsulate the entire user experience. This component will be strategically placed on a custom Lightning Page (e.g., an App Page) to offer users a dedicated and streamlined workspace for managing their deployments.

The LWC's layout will be logically structured, typically featuring:

A search bar and filter options prominently displayed at the top for quick access.

A main lightning-datatable to present the searchable metadata components.

A dedicated section (e.g., a sidebar or a collapsible panel) to display the list of currently selected components, providing a clear overview of the deployment manifest.

A form area for configuring specific deployment options, such as the target organization, comments, and test settings, culminating in a clearly visible "Deploy" button.

The user interaction flow is designed to be highly intuitive:

Search & Filter: The user begins by entering search criteria (e.g., "AccountTrigger", "MyFlow") into a search input field and can optionally narrow results by selecting specific metadata types (e.g., "ApexClass", "Flow", "CustomObject") using a dropdown or combobox.

Results Display: The lightning-datatable dynamically populates with metadata components that match the user's search and filter criteria.

Component Selection: Users can easily select one or more rows (representing metadata components) from the datatable using its built-in multi-select checkbox functionality.

Selected List Management: As components are selected, they are added to a separate, persistent list within the LWC. This list provides a real-time summary of the components chosen for the upcoming deployment, ensuring transparency and ease of review.

Deployment Configuration: The user then proceeds to fill in required deployment parameters within a dedicated form. These parameters include the target org alias, descriptive deployment comments, the desired test level, and optionally, specific Apex test classes to execute, along with rollback options.

Initiate Deployment: A click on the "Deploy" button triggers the underlying Apex callout to the External Deployment Engine, initiating the deployment process.

Status Feedback: Throughout the deployment lifecycle, the LWC provides real-time status updates. This includes displaying a lightning-spinner during asynchronous operations , showing progress indicators, and updating the UI with the deployment's current status (e.g., "In Progress," "Succeeded," "Failed"). Links to the detailed

Deployment__c record will also be provided for in-depth log review.

 

3.2.2. Metadata Search and Filtering Implementation
 

The effectiveness of the LWC hinges on its ability to efficiently search and filter metadata components.

Search Input: A lightning-input component will be used to capture the user's search string. To provide granular control over the search scope, a lightning-combobox will allow users to select specific metadata types (e.g., ApexClass, Flow, CustomObject) to narrow down the search results.

Filtering Strategy (Server-Side): Given the potential for a very large number of metadata components within a Salesforce organization, implementing server-side filtering is a critical design choice for ensuring optimal performance and scalability. The LWC will transmit the user's search term and selected metadata types to an Apex controller method. This Apex method will then be responsible for constructing and executing optimized SOQL queries against the Tooling API to retrieve only the matching components, thereby minimizing data transfer and processing on the client side.

Debouncing for Search: To enhance user experience and prevent excessive Apex calls, a debouncing mechanism will be implemented for the search input field. This technique introduces a short delay (e.g., 300 milliseconds) after the user stops typing before the Apex call is triggered. This prevents unnecessary server requests on every keystroke, significantly improving the responsiveness and overall performance of the search functionality.

 

3.2.3. Datatable Functionality
 

The lightning-datatable component is central to displaying and managing metadata search results.

Component Selection: The lightning-datatable component will be utilized to effectively display the search results.

Multi-select Capability: The datatable will be configured to allow multi-selection of rows. This is achieved by enabling the built-in checkbox column and handling the onrowselection event, while using the selected-rows attribute to manage the state of selected items. This functionality is essential for users to easily pick multiple components to include in a single deployment.

Pagination / Infinite Scrolling: To efficiently handle potentially large result sets returned from Tooling API queries without encountering UI performance bottlenecks or exceeding client-side data limits, infinite scrolling will be implemented. This feature utilizes the enable-infinite-loading and onloadmore attributes of the lightning-datatable. This allows the LWC to initially load a manageable subset of data and then progressively fetch more records from the server as the user scrolls towards the end of the table, providing a seamless browsing experience.

A critical consideration in this design pertains to the capabilities of the Salesforce Tooling API. A significant constraint exists: the Body field, which contains the actual code or definition of metadata components (such as Apex Classes or Flows), cannot be queried when the SOQL query result contains more than one record. This platform limitation means that the LWC's search results datatable can only display basic identifying information for multiple metadata components, such as

Id, Name, Type, and LastModifiedDate. The full metadata content will not be retrieved and displayed directly within the search results table. Instead, the comprehensive retrieval of the metadata body (e.g., the XML definition) will be handled by the External Deployment Engine. This engine will use the Metadata API's retrieve() call (which does not have the same multi-record Body field limitation) at the precise moment of deployment. This design approach is a direct consequence of the Tooling API constraint and ensures that the search functionality remains performant and scalable, while the full content is handled at the appropriate stage of the deployment process.

Persistent Selection: Robust logic will be implemented to ensure that selected rows remain highlighted and tracked consistently, even when the user navigates through different pages of the datatable or loads additional data via infinite scrolling. This maintains a coherent and persistent user experience, allowing users to build their deployment package across a large dataset without losing track of their selections.

TABLE: LWC Datatable Performance Best Practices

This table summarizes key strategies for maintaining the responsiveness and scalability of the LWC, particularly when dealing with potentially large datasets of metadata components. These practices are directly integrated into the design to ensure optimal user experience and efficient resource utilization.

Practice

Description

Rationale/Benefit

Relevant Snippet IDs

Server-side Filtering

Filtering of data is performed by Apex on the Salesforce server.

Efficient for large datasets, reduces client-side processing load, minimizes data transfer over the network.

 

Debouncing Search Input

Introduces a delay before executing a search query after user input.

Prevents excessive Apex calls on every keystroke, improving responsiveness and reducing server load.

 

Infinite Scrolling / Lazy Loading

Loads a subset of data initially, then fetches more as the user scrolls.

Improves initial load times, reduces memory consumption on the client, provides a seamless user experience for large lists.

 

Limiting Query Fields

Apex queries retrieve only the necessary fields (Id, Name, Type, LastModifiedDate).

Reduces data transfer size, optimizes query performance, and adheres to Tooling API Body field limitation for multiple records.

 

Persistent Row Selection

Logic to maintain selected rows across different pages/loads of the datatable.

Ensures a consistent user experience, allows users to select components from a large dataset without losing previous selections.

 

 

3.2.4. Deployment Initiation and Status Display
 

The LWC provides the interface for users to initiate deployments and monitor their progress.

Form Inputs: Standard LWC components such as lightning-input and lightning-textarea will be used to capture deployment-specific details. This includes the target organization alias, descriptive user comments for the deployment, and other relevant parameters. A lightning-combobox will be used for selecting the Test_Level__c, and a lightning-input (or lightning-textarea for multiple) for specifying Run_Tests__c.

Deploy Button: A prominent lightning-button will be configured to trigger the AuraEnabled Apex method. This method is responsible for initiating the entire asynchronous deployment process by making the callout to the External Deployment Engine.

Status Display: To provide a responsive user experience, the LWC will incorporate a lightning-spinner to indicate loading states during asynchronous operations. Furthermore, the UI will dynamically update to display the current

Status__c of the associated Deployment__c record (e.g., "Pending," "In Progress," "Succeeded," "Failed"). This real-time feedback can be enhanced with progress indicators or direct links to the detailed Deployment__c record for a comprehensive review of the deployment logs.

 

3.3. Apex Controller Design
 

The Apex controller serves as the crucial backend for the LWC, handling interactions with Salesforce APIs, data persistence, and orchestrating the callouts to the external deployment service.

 

3.3.1. Tooling API Integration for Metadata Querying
 

The Apex controller will facilitate querying metadata components from the current Salesforce organization using the Salesforce Tooling API.

Endpoint Construction: The Apex controller will dynamically construct the Tooling API REST endpoint. This is achieved by concatenating the Salesforce base URL (obtained via URL.getSalesforceBaseUrl().toExternalForm()) with the Tooling API service path and the desired API version (e.g., /services/data/vXX.X/tooling/query?q=). It is best practice to use the latest supported API version (e.g.,

v64.0 for Summer '25) to leverage the most recent features and capabilities.

Authentication: For these internal Tooling API callouts, the UserInfo.getSessionId() will be used as the Bearer token in the Authorization header of the HTTP request. This ensures that the queries execute within the security context of the currently logged-in user, respecting their profile and permission set access to metadata.

Supported Metadata Types: The Apex controller will specifically focus on querying the metadata types requested by the user, such as ApexClass, Flow, and CustomObject. The Tooling API provides fine-grained access to these metadata types, making it suitable for interactive applications.

Querying Limitations and Pagination:

A critical consideration in the design of the metadata querying functionality is a specific limitation of the Salesforce Tooling API. The Body field, which contains the actual source code or definition of metadata components like Apex Classes or Flows, cannot be queried if the SOQL query result contains more than one record. Attempting to do so will result in an error. This platform constraint dictates that Apex queries to the Tooling API for the LWC's search functionality will be restricted to retrieving only basic identifying information (e.g.,

Id, Name, Type, NamespacePrefix, LastModifiedDate, ApiVersion). The comprehensive retrieval of the full metadata content (e.g., the complete XML definition) will be deferred to the External Deployment Engine, which will utilize the Metadata API's retrieve() call at the time of deployment, as the Metadata API does not share this specific limitation for bulk content retrieval. This approach ensures the search function remains performant and scalable.

For Salesforce organizations with a substantial number of metadata components, even queries for basic identifying information (e.g., SELECT Id, Name FROM ApexClass) can return thousands of records. Standard SOQL OFFSET clauses are limited to 2000 records, which is insufficient for large datasets. To address this, the Tooling API REST

query resource supports pagination via a nextRecordsUrl included in its response when the result set is too large. The Apex controller will implement a robust iterative querying mechanism:

An initial HTTP GET request will be made to the Tooling API query endpoint.

The JSON response will be parsed to extract the records array and to check for the presence of a nextRecordsUrl and a done flag.

If a nextRecordsUrl is present and the done flag indicates that not all records have been retrieved, subsequent HTTP GET requests will be made to the nextRecordsUrl until all records are retrieved or the done flag is true.

This ensures that the LWC can display a comprehensive list of all relevant metadata components, regardless of the organization's size, by effectively traversing through all paginated results.

TABLE: Tooling API Query Limitations and Pagination Strategies

This table is crucial for understanding the technical constraints when interacting with the Salesforce Tooling API from Apex. It highlights critical API limitations and provides the necessary workarounds for scalable metadata querying, directly addressing the performance and robustness requirements of the solution.

Limitation

Description

Impact

Recommended Solution

Relevant Snippet IDs

Body Field Query Restriction

The Body field (containing metadata content/source code) cannot be queried for more than one record in a single Tooling API SOQL query.

LWC search results cannot display full metadata content for multiple components.

LWC displays only Id, Name, Type. Full content retrieval is handled by External Deployment Engine using Metadata API at deployment time.

 

SOQL OFFSET Limit

The OFFSET clause in SOQL queries has a maximum limit of 2000 records.

Standard SOQL pagination is ineffective for datasets larger than 2000 records.

Not applicable directly to Tooling API REST queries, but a general SOQL limitation.

 

Large Query Result Sets

Tooling API queries can return thousands of records, exceeding single response limits.

Incomplete data retrieval for metadata search/selection without proper handling.

Implement iterative HTTP callouts to follow nextRecordsUrl in the Tooling API REST query response to retrieve all batches of records.

 

API Callout Limits

Salesforce imposes limits on synchronous (10s timeout, 100 callouts/transaction) and asynchronous (120s timeout) callouts.

Can lead to CalloutException or governor limit issues if not managed properly.

Use Queueable Apex for all external callouts to ensure asynchronous execution and manage transaction boundaries. Implement retry logic.

 

 

3.3.2. Data Persistence Logic
 

The Apex controller is responsible for persisting user selections and deployment details into the custom objects.

Upon receiving the list of selected component IDs and types from the LWC, the Apex controller will initiate the data persistence process.

A new Deployment__c record will be created. This record will capture essential information such as the source and target organization aliases, any user-entered comments, and the initial deployment options (e.g., Check_Only__c, Test_Level__c). The initial Status__c will typically be set to Pending or InProgress.

For each individual metadata component selected by the user, a corresponding Metadata_Selection__c child record will be created. These child records will be linked to the newly created Deployment__c record via the Master-Detail relationship, ensuring a clear, auditable, and structurally sound record of all components included in that specific deployment.

 

3.3.3. External Callout to Deployment Engine
 

The Apex controller orchestrates the communication with the External Deployment Engine to initiate the actual metadata deployment.

Asynchronous Execution: The callout to the External Deployment Engine will be performed using Queueable Apex. This is a critical best practice for any long-running operations or external integrations within Salesforce. Executing the callout in a separate

Queueable job ensures that it runs in an asynchronous transaction, preventing the user interface from blocking, avoiding common governor limits (such as the "DML before callout" restriction), and isolating potential callout failures from the user's current synchronous transaction.

Named Credentials: All HTTP callouts from Salesforce Org A to the External Deployment Engine must utilize a Named Credential. Named Credentials are the gold standard for managing external system authentication in Salesforce. They offer numerous advantages: centralized credential management, automatic authentication handling (Salesforce manages the OAuth token or JWT assertion), environment-specific configurations (allowing different endpoints for sandboxes and production), enhanced security through encryption, and simplified deployment across various organizations. The Apex code will reference the Named Credential using the

callout:YourNamedCredential/api/deploy syntax, abstracting the actual endpoint URL and authentication details.

JSON Payload Construction: The Apex controller will construct a JSON payload that strictly conforms to the sample structure specified in the POC Summary. This payload will include sourceOrgAlias, targetOrgAlias, a detailed list of components (each specified by its type and name), the packageXmlVersion (e.g., "59.0"), and the deployOptions (e.g., checkOnly, runTests, testLevel). The JSON.serialize() method in Apex will be used to convert the Apex objects representing this data into the required JSON format for transmission.

HTTP Request: Standard Apex HttpRequest and Http classes will be used to send a POST request to the Named Credential endpoint. The

request.setEndpoint('callout:YourNamedCredential/api/deploy') syntax will ensure that the Named Credential's benefits are fully leveraged.

 

3.3.4. Robust Error Handling and Retry Mechanisms
 

Given that external callouts and deployments are inherently susceptible to transient network issues, API limits, or service unavailability, robust error handling and retry mechanisms are paramount.

Try-Catch Blocks: All Apex code involving external callouts and DML operations will be meticulously wrapped in try-catch blocks. This ensures that System.CalloutException (which can occur due to network problems, timeouts, or invalid endpoints) and other potential exceptions (e.g., DML exceptions during record creation/update) are gracefully handled.

Status Code Checking: After receiving an HttpResponse from the External Deployment Engine, the Apex controller will explicitly check the HttpResponse.getStatusCode(). Any status code other than 200 (OK) will be treated as an error, triggering specific error handling logic. This includes client errors (4xx) and server errors (5xx), as well as application-level errors indicated within a 200 OK response body.

Comprehensive Logging: Detailed logs of all callout requests, the responses received, and any errors encountered will be systematically recorded. This information will be stored in the Deployment_Log__c (Rich Text Area) field on the associated Deployment__c record. This practice provides a crucial, centralized audit trail for every deployment attempt and significantly aids in troubleshooting and post-mortem analysis.

Retry Mechanism: For transient callout failures (e.g., temporary network glitches, brief service unavailability, or specific HTTP status codes like 429 Too Many Requests), a robust retry mechanism will be implemented. This can be achieved through:

Queueable Chaining with Delay: If a retryable error occurs, the current Queueable job can enqueue a new Queueable job. This subsequent job can be configured to execute after a short delay (e.g., using System.enqueueJob with a future time, though direct chaining is more common for immediate retries). A custom field on Deployment__c (e.g., Retry_Count__c) will track the number of attempts to prevent infinite loops. A predefined maximum retry limit (e.g., 3-5 times) will be enforced before marking the deployment as a persistent failure.

Platform Events (for Decoupled Retries): For more advanced, decoupled retry scenarios, a platform event could be published upon a retryable failure. This event could then trigger a separate flow or Apex class to re-enqueue the callout, providing greater flexibility and resilience.

Circuit Breaker Pattern: To prevent cascading failures and protect Salesforce from repeatedly calling a persistently failing External Deployment Engine, the implementation of a circuit breaker pattern will be considered. This pattern involves:

Tracking Failures: A custom setting or custom metadata type could be used to track the number of consecutive failures for the Named Credential endpoint.

Opening the Circuit: If the number of consecutive failures exceeds a predefined threshold, the circuit "opens," meaning no further callouts will be attempted to that endpoint for a specified "cool-down" period. Any subsequent attempts during this period will immediately fail locally without making an actual external callout.

Half-Opening: After the cool-down period, the circuit "half-opens," allowing a single "test" callout. If this test callout is successful, the circuit "closes" (resuming normal operation); otherwise, it "re-opens" for another cool-down period. This pattern significantly enhances the resilience of the integration.

 

3.3.5. Security Context and Session Management
 

The security context under which Apex code executes and how session IDs are managed are crucial for secure and compliant operations.

Apex code, by default, executes in system context, meaning it runs with full permissions regardless of the current user's profile. However, when making Tooling API calls using UserInfo.getSessionId(), these calls execute in the context of the logged-in user. This implies that the user initiating the deployment must possess the necessary permissions to query metadata via the Tooling API.

The Apex controller will enforce that the user has the Metadata_Deployer__c permission set assigned. This permission set will grant the required access to the custom objects (Deployment__c, Metadata_Selection__c), the Apex classes involved in the LWC data retrieval, Tooling API calls, and callout initiation, ensuring that operations are performed by authorized individuals.

 

4. Detailed Design: External Deployment Engine (Middleware or Org B)
 

The External Deployment Engine is a pivotal component responsible for executing the actual metadata deployment. Its design requires careful consideration of API interactions, authentication, and error handling.

A fundamental architectural decision for enabling cross-org metadata deployments as described is the absolute necessity of an external middleware. This stems from a core Salesforce platform constraint: Apex within one Salesforce organization cannot directly invoke the Metadata API of another distinct Salesforce organization. Consequently, the initial consideration of using a dedicated Salesforce Org B as a direct deployment engine via Apex callouts from Org A is not a feasible approach for cross-org operations. The middleware, therefore, becomes the indispensable intermediary for orchestrating deployments between distinct Salesforce environments.

 

4.1. API Endpoint Specification (REST API for receiving deployment requests)
 

The External Deployment Engine will expose a RESTful API endpoint to receive deployment requests from Salesforce Org A.

Technology Choice: A Node.js application hosted on Heroku is a highly suitable choice for implementing the External Deployment Engine. Heroku offers a robust, scalable platform that fully supports Node.js applications. Furthermore, Heroku AppLink provides a streamlined mechanism for securely exposing API services to Salesforce, simplifying the integration considerably.

Endpoint Definition: A specific RESTful API endpoint, for example, /api/deploy, will be exposed by the middleware. This endpoint will be configured to accept HTTP POST requests originating from Salesforce Org A.

Request Body Validation: The API will be designed to expect a JSON payload that strictly conforms to the sample structure provided in the POC Summary. The middleware will incorporate robust validation mechanisms for this incoming JSON payload. This validation will ensure that all required parameters (e.g., sourceOrgAlias, targetOrgAlias, the components list) are present, correctly formatted, and adhere to expected data types, preventing malformed requests from proceeding.

Authentication: The middleware endpoint itself must be secured. It will be responsible for validating the authentication token sent by Salesforce Org A via the Named Credential. This validation process could involve verifying an OAuth token or a JWT assertion provided by Salesforce.

TABLE: Sample API Payload Structure

This table provides a clear and detailed contract for the JSON payload that Salesforce Org A will transmit to the External Deployment Engine. This precise definition is crucial for ensuring that both the Apex controller (generating the payload) and the middleware (consuming and parsing the payload) are perfectly aligned on the data structure. Such clarity is vital for an AI agent to accurately generate the code for both sides of this integration.

JSON Key

Data Type

Description

Example Value

Correspondence to Metadata API DeployOptions

sourceOrgAlias

String

Alias of the Salesforce org from which metadata will be retrieved.

"dev-org"

N/A (Internal to solution)

targetOrgAlias

String

Alias of the Salesforce org to which metadata will be deployed.

"prod-org"

N/A (Internal to solution)

components

Array of Objects

List of metadata components to deploy. Each object contains type and name.

``

N/A (Part of manifest)

packageXmlVersion

String

API version for the package.xml manifest.

"59.0"

N/A (Metadata API version)

deployOptions

Object

Object containing various deployment parameters.

{ "checkOnly": false, "runTests":, "testLevel": "RunSpecifiedTests" }

Directly maps to DeployOptions parameters

deployOptions.checkOnly

Boolean

If true, performs a test deployment (validation) without saving.

false

checkOnly

deployOptions.runTests

Array of Strings

List of Apex test class names to run.

``

runTests

deployOptions.testLevel

String

Test execution level (NoTestRun, RunSpecifiedTests, RunLocalTests, RunAllTestsInOrg).

"RunSpecifiedTests"

testLevel

deployOptions.rollbackOnError

Boolean

If true, any failure causes a complete rollback.

true

rollbackOnError

deployOptions.ignoreWarnings

Boolean

If true, deployment continues even if warnings occur.

false

ignoreWarnings

 

4.2. Metadata Retrieval and Deployment Logic
 

The core function of the External Deployment Engine is to orchestrate the retrieval of metadata from the source organization and its subsequent deployment to the target organization.

Authentication to Target Org (and Source Org for Retrieval): The middleware will require secure authentication to both the source Salesforce organization (from which metadata components are retrieved) and the target Salesforce organization (where they are deployed). OAuth 2.0 JWT Bearer Flow is highly recommended for this server-to-server integration. This flow is ideal because it enables secure programmatic access without requiring direct user interaction, making it suitable for automated processes. The implementation involves:

Connected App Creation: A Connected App must be meticulously created within each Salesforce organization (both source and all potential target orgs) that the middleware intends to interact with. This Connected App will be configured to utilize a digital signature, requiring the upload of a self-signed X.509 certificate. Appropriate OAuth Scopes (e.g.,

api, full) must be selected to grant the necessary permissions for metadata operations.

Certificate Management: The middleware application will be responsible for securely storing the private key that corresponds to the uploaded X.509 certificate. This private key is essential for signing the JWT assertions.

JWT Assertion Exchange: For each API call to a Salesforce organization, the middleware will programmatically construct a JSON Web Token (JWT) assertion. This assertion will be signed using its securely stored private key. The signed JWT is then exchanged with Salesforce's OAuth 2.0 token endpoint to obtain a valid access token. This access token is then used to authorize subsequent Metadata API calls.

Metadata Retrieval (from Source Org):

Upon receiving a deployment request, the middleware will parse the components list from the incoming JSON payload.

It will then dynamically construct a package.xml manifest. This manifest is a crucial XML file that precisely specifies the metadata types and names of the components to be retrieved from the source Salesforce organization.

The middleware will then invoke the Salesforce Metadata API retrieve() call (or, alternatively, internally execute SFDX CLI commands such as sfdx force:source:retrieve or sf project retrieve). This operation fetches the specified metadata components from the sourceOrgAlias using the authenticated connection established via the JWT Bearer Flow.

The successful result of the retrieve() call will be a ZIP file containing the metadata components in their file-based XML representation, ready for deployment.

Metadata Deployment (to Target Org):

Once the metadata components are successfully retrieved and packaged into a ZIP file, the middleware proceeds with the deployment.

It will then invoke the Salesforce Metadata API deploy() call (or internally execute SFDX CLI commands like sfdx force:source:deploy or sf project deploy) to push these components to the designated targetOrgAlias.

Deployment Options: Crucially, the deployOptions object received in the initial payload from Salesforce Org A (e.g., checkOnly, runTests, testLevel, rollbackOnError, ignoreWarnings) will be directly passed as parameters to the Metadata API deploy() call. This ensures that the deployment behavior (such as performing a validation-only check, executing specific tests, or handling warnings) is precisely controlled by the user's selections made in the LWC.

TABLE: Metadata API Deployment Options and Parameters

This table provides a comprehensive reference for the various parameters available when initiating a Salesforce Metadata API deployment. This level of detail is critical for an AI agent to accurately construct the deployment request and for developers to fully understand the range of deployment behaviors that can be configured.

Parameter Name

Data Type

Description

Default Value

Valid Values

Notes

Relevant Snippet IDs

allowMissingFiles

Boolean

If files specified in package.xml are not in the.zip, allows deployment to succeed.

false

true, false

Do not set true for production orgs.

 

autoUpdatePackage

Boolean

If a file is in the.zip but not in package.xml, automatically adds it.

false

true, false

Reserved for future use. Do not set true for production orgs.

 

checkOnly

Boolean

If true, performs a test deployment (validation) without saving components.

false

true, false

Useful for verifying deployment readiness.

 

ignoreWarnings

Boolean

If true, deployment completes successfully even if warnings are generated.

false

true, false

If false (default), warnings cause deployment failure.

 

performRetrieve

Boolean

Reserved for internal use.

false

true, false

Do not use.

 

rollbackOnError

Boolean

If true, any failure causes a complete rollback.

false

true, false

Must be true for production orgs.

 

runTests

String

A list of Apex test class names to run during deployment.

null

Array of class names (e.g., ``)

Requires testLevel to be RunSpecifiedTests.

 

singlePackage

Boolean

Reserved for future use.

false

true, false

Do not use.

 

testLevel

String

Defines the level of Apex tests to execute.

NoTestRun (dev orgs), RunLocalTests (prod orgs with Apex)

NoTestRun, RunSpecifiedTests, RunLocalTests, RunAllTestsInOrg

NoTestRun only for dev environments.

 

 

4.3. Asynchronous Status Reporting and Callback to Salesforce
 

Given that the Metadata API deploy() call is inherently asynchronous , the External Deployment Engine must implement a robust mechanism for monitoring the deployment's progress and reporting its final status back to Salesforce Org A.

Deployment Monitoring: After initiating a deployment via the deploy() call, the External Deployment Engine will continuously monitor its status. This is achieved by periodically polling the checkDeployStatus() endpoint of the Metadata API. The

deployId obtained from the initial deploy() call is used to query the status of that specific deployment. The polling interval should be carefully configured to balance responsiveness (providing timely updates) with adherence to Salesforce API limits.

Status Callback to Salesforce Org A: Once the deployment process reaches a terminal state (i.e., Succeeded, SucceededPartial, Failed, or Canceled), the External Deployment Engine will send a comprehensive status update back to Salesforce Org A.

Recommended Mechanism: A dedicated REST endpoint exposed by Salesforce Org A (implemented as an @RestResource Apex class) is the most straightforward and reactive method for this callback. The middleware will make an HTTP POST request to this specifically designed endpoint.

The callback payload will include the Deployment_ID__c (which originated from Org A's initial request), the Metadata API deployId, and the comprehensive DeployResult object from the Metadata API. This

DeployResult object contains vital information such as the final status, any error messages, and detailed breakdowns of component successes or failures.

Upon receiving this callback, an Apex controller method within Org A (triggered by the @RestResource endpoint) will process the incoming payload. It will then update the corresponding Deployment__c record's Status__c field and populate the Deployment_Log__c field with the detailed results, ensuring an accurate and auditable history of the deployment.

 

4.4. Authentication and Authorization (JWT Bearer Flow/OAuth 2.0 for secure communication)
 

Secure communication between the External Deployment Engine and the Salesforce organizations (both source for retrieval and target for deployment) is paramount.

Middleware to Target Org (and Source Org for Retrieval): As previously established, OAuth 2.0 JWT Bearer Flow is the preferred and most secure method for this server-to-server authentication. This flow is ideal because it enables secure programmatic access without requiring direct user interaction, making it highly suitable for automated processes. The implementation involves several key steps:

Connected App Setup: A Salesforce Connected App must be meticulously created within each Salesforce organization (i.e., the source org for metadata retrieval and all potential target orgs for deployment) that the middleware will interact with. This Connected App will be configured to utilize a digital signature, which requires the upload of a self-signed X.509 certificate. Furthermore, appropriate OAuth Scopes (e.g.,

api, full) must be selected within the Connected App to grant the necessary permissions for metadata operations.

Certificate Management: The middleware application will be responsible for securely storing the private key that corresponds to the uploaded X.509 certificate. This private key is a cryptographic asset essential for signing the JWT assertions.

JWT Assertion Exchange: For each API call to a Salesforce organization, the middleware will programmatically construct a JSON Web Token (JWT) assertion. This assertion will contain claims such as the issuer (Connected App's consumer key), subject (username of the integration user in Salesforce), and audience (Salesforce login URL). The JWT assertion is then signed using the securely stored private key. This signed JWT is subsequently exchanged with Salesforce's OAuth 2.0 token endpoint to obtain a valid access token. This access token is then used to authorize all subsequent Metadata API calls, ensuring secure and authenticated communication.

 

4.5. Scalability, Reliability, and Monitoring Considerations
 

Designing the External Deployment Engine for scalability, reliability, and effective monitoring is crucial for its long-term success.

Concurrency: The External Deployment Engine must be designed to efficiently handle multiple concurrent deployment requests originating from Salesforce Org A. This necessitates an architecture that supports asynchronous processing within the middleware itself (e.g., leveraging Node.js's event loop, or implementing worker queues for heavier tasks) to prevent bottlenecks and ensure responsiveness.

Error Handling (Middleware): Comprehensive error handling must be implemented within the middleware for all interactions with the Salesforce Metadata API. This includes anticipating and gracefully managing various error scenarios such as Salesforce API limits being hit (REQUEST_LIMIT_EXCEEDED), network connectivity issues, validation failures during deployment, or unexpected responses from the Metadata API. All errors should be logged with sufficient detail to facilitate rapid diagnosis.

Retry Logic (Middleware): To enhance resilience, the middleware will incorporate robust retry logic for transient Metadata API errors. This includes errors like

UNABLE_TO_LOCK_ROW (due to database contention) or temporary service unavailability (often indicated by 5xx HTTP errors from Salesforce). An exponential backoff strategy is recommended for retries, where the delay between attempts increases with each subsequent retry, preventing overwhelming the API during periods of instability.

Monitoring and Logging: Implementing robust logging within the middleware application (e.g., using a dedicated logging framework like Winston for Node.js) is essential. This logging will capture detailed information about each deployment request, its progress, success or failure, and any encountered errors. Furthermore, integrating with Heroku's built-in logging capabilities or an external monitoring service (e.g., Splunk, DataDog) is crucial. This integration provides comprehensive operational visibility, allowing administrators to track deployment success rates, identify common failure reasons, monitor performance metrics, and proactively troubleshoot issues.

 

5. Security and Access Management
 

Security is a foundational aspect of the Declarative Metadata Deployer, ensuring that metadata operations are performed securely, by authorized individuals, and in compliance with organizational policies.

 

5.1. Named Credentials Configuration and Best Practices
 

Named Credentials are the cornerstone for establishing secure and simplified outbound callouts from Salesforce Org A to the External Deployment Engine.

Purpose: Named Credentials abstract the external endpoint URL and all authentication details, preventing the hardcoding of sensitive information (like API keys or passwords) directly within Apex code. This significantly enhances security and simplifies maintenance.

Configuration: A Named Credential will be meticulously created within Salesforce Org A. The URL for this Named Credential will point directly to the External Deployment Engine's API endpoint. The authentication protocol for this Named Credential should be carefully selected. While OAuth 2.0 or JWT can be leveraged if the middleware is designed to act as an OAuth provider, for simplicity in a custom internal tool, a secure API Key (transmitted as a custom header) or a more basic authentication method might be considered, though these are generally less secure than full OAuth flows. The most robust approach would involve a client credentials flow or similar if the middleware can support it.

Benefits: The use of Named Credentials offers numerous advantages: centralized credential management, automatic authentication handling by Salesforce, environment-specific configurations (allowing different endpoints for sandboxes and production without code changes), enhanced security through encryption of credentials, and simplified deployment across various Salesforce organizations.

 

5.2. Permission Set Design (Metadata_Deployer__c) for Controlled Access
 

To enforce the principle of least privilege and ensure that only authorized users can interact with the Declarative Metadata Deployer, a dedicated permission set, Metadata_Deployer__c, will be designed.

Purpose: This permission set will grant granular access to the Declarative Metadata Deployer's LWC, custom objects, and underlying Apex classes. It ensures that users have precisely the permissions required to perform their roles without unnecessary elevated access.

Permissions to Include:

Custom Object Permissions: Grant Read, Create, and Edit permissions on both the Deployment__c and Metadata_Selection__c custom objects. This allows users to initiate new deployments, view existing ones, and track their status.

Apex Class Access: Provide Execute access to all Apex controllers and utility classes that are involved in LWC data retrieval (e.g., Tooling API queries), data persistence, and the initiation of external callouts.

External Credential/Named Credential Access: Grant access to the specific Named Credential configured for making callouts to the External Deployment Engine. This ensures that the Apex code can securely authenticate to the middleware.

Metadata API Permissions: The user who initiates the deployment (whose session is used for Tooling API queries and whose credentials are implicitly used by the middleware to authenticate to the target org via the Connected App) must possess the necessary permissions to perform metadata operations. Specifically, the "Modify Metadata Through Metadata API Functions" permission is required, or, more broadly, "Modify All Data". Enabling "Deploy Change Sets" or "Author Apex" permissions automatically grants "Modify Metadata Through Metadata API Functions".

LWC Component Access: Ensure that the declarativeMetadataDeployer LWC component is accessible to users assigned this permission set.

 

5.3. Data Security and Compliance Considerations
 

Beyond access control, broader data security and compliance measures are essential for the solution.

Data Minimization: Ensure that no sensitive or personally identifiable information (PII) is stored unnecessarily within the custom objects or logs. Only data directly relevant to tracking the deployment process should be retained.

Secure Communication: All communications between Salesforce Org A and the External Deployment Engine, as well as between the External Deployment Engine and target Salesforce organizations, must exclusively use HTTPS to encrypt data in transit. This protects sensitive metadata and authentication tokens from interception.

Regular Audits: Implement a practice of regular security audits for both the middleware application and the Salesforce configurations. This includes reviewing access logs, authentication mechanisms, and data storage practices to identify and mitigate potential vulnerabilities.

 

6. Deployment and Packaging Strategy
 

The Declarative Metadata Deployer is intended for internal distribution across 8squad environments, leveraging an unmanaged package for ease of installation.

 

6.1. Unmanaged Package Structure and Contents
 

The solution will be distributed as an unmanaged package within Salesforce. This choice simplifies the initial sharing and installation process across various 8squad environments.

Components Included: The unmanaged package will contain all necessary Salesforce components for the Declarative Metadata Deployer to function within Salesforce Org A:

Custom Objects: The Deployment__c and Metadata_Selection__c objects, along with all their defined custom fields.

Lightning Web Components: The declarativeMetadataDeployer LWC, comprising its HTML template, JavaScript controller, and configuration XML file.

Apex Classes: All Apex controllers and utility classes developed for Tooling API interactions, external callouts, data persistence, and status callbacks.

Permission Set: The Metadata_Deployer__c permission set, which defines the necessary object, class, and component access for users of the tool.

Remote Site Settings: Configuration for the Tooling API endpoint and the External Deployment Engine's endpoint will be included in the package to allow Apex callouts.

Named Credential: The definition of the Named Credential (without the actual authentication details) used for connecting to the External Deployment Engine will be part of the package.

A significant consideration with the choice of an unmanaged package is its inherent limitation regarding upgrades. While convenient for initial distribution across 8squad environments, an unmanaged package offers no upgrade path. This means that any future enhancements, bug fixes, or new features will require manual re-deployment of individual components or the distribution of a new unmanaged package. This can lead to version management challenges and increased manual effort for maintenance over time. This is a trade-off accepted for the simplicity of initial installation and internal sharing.

 

6.2. Post-Installation Configuration Steps
 

After the unmanaged package is installed in a Salesforce organization, several manual configuration steps are required to ensure full functionality.

Named Credential Setup: The actual authentication details (e.g., the external endpoint URL, API keys, or OAuth parameters) for the Named Credential must be manually configured in each target Salesforce organization after the package installation. This is a security measure to prevent credentials from being bundled directly in the package.

External Deployment Engine Setup: The External Deployment Engine (e.g., the Heroku-hosted Node.js application) must be deployed and configured separately from the Salesforce package. This involves setting up the server, deploying the application code, and configuring its environment variables (e.g., Salesforce Connected App credentials).

Connected App Setup (in Target Orgs): For the External Deployment Engine to authenticate to target Salesforce organizations using the JWT Bearer Flow, a Salesforce Connected App must be created and configured in each target Salesforce org. This involves uploading the X.509 certificate and setting appropriate OAuth scopes.

Permission Set Assignment: The Metadata_Deployer__c permission set must be manually assigned to all relevant users who require access to the Declarative Metadata Deployer LWC and its functionalities.

 

6.3. Considerations for Multi-Org Environments
 

Deploying this solution across multiple Salesforce organizations (both source and target) requires specific considerations.

Each Salesforce organization (both the source org where the LWC is installed and any target orgs for deployment) will necessitate its own specific Named Credential and Connected App configurations. This ensures secure and isolated authentication for each environment.

The External Deployment Engine needs to be robustly designed to manage authentication to multiple Salesforce organizations simultaneously. This implies a mechanism within the middleware to dynamically select and use the correct authentication credentials (e.g., client ID, private key, username) based on the sourceOrgAlias and targetOrgAlias provided in each deployment request.

 

7. Testing Strategy
 

A comprehensive testing strategy is essential to ensure the quality, reliability, and security of the Declarative Metadata Deployer.

 

7.1. Unit Testing (Apex with HttpCalloutMock, LWC Jest tests)
 

Apex Unit Testing:

All Apex classes will undergo rigorous unit testing. A critical aspect of this is the extensive use of the HttpCalloutMock interface. This interface is indispensable because actual external callouts are strictly prohibited in Apex unit tests.

HttpCalloutMock allows developers to simulate responses from both the Tooling API and the External Deployment Engine, enabling comprehensive testing of callout logic, JSON parsing, and error handling without making real network requests.

Unit tests will cover all Apex methods, including: Tooling API query logic (with mocked responses simulating large datasets and nextRecordsUrl scenarios), data persistence to Deployment__c and Metadata_Selection__c objects, and the initiation logic for external callouts.

A minimum of 100% code coverage will be targeted for all Apex classes to ensure thorough testing.

LWC Jest Tests:

Jest will be utilized for unit testing the Lightning Web Components. These tests will focus on validating the LWC's user interface rendering, responsiveness to user interactions (e.g., search input, button clicks), event handling, and client-side data manipulation.

Apex methods invoked by the LWC (e.g., @wire methods, AuraEnabled methods) will be mocked using Jest's capabilities, allowing for isolated testing of the LWC's client-side behavior without requiring a Salesforce org.

 

7.2. Integration Testing (End-to-end flow from LWC to Deployment Engine)
 

Integration testing will validate the seamless interaction between all components of the solution.

The complete end-to-end flow will be tested, starting from user interaction with the LWC, through the Apex controller, to the External Deployment Engine, and back to Salesforce Org A for status updates.

Dedicated sandbox environments will be provisioned for integration testing. These environments will mimic production configurations as closely as possible, including Named Credential setups and Connected App configurations for the External Deployment Engine.

Verification will include confirming the correct construction of JSON payloads at each integration point (LWC to Apex, Apex to Middleware) and accurate parsing of JSON responses (Middleware to Apex). This ensures data integrity and correct communication protocols.

 

7.3. User Acceptance Testing (UAT) Scenarios
 

User Acceptance Testing (UAT) will involve key stakeholders and end-users to validate that the solution meets business requirements and provides a satisfactory user experience.

User Experience Validation: UAT will focus on validating the intuitive nature of the LWC for searching, selecting, and initiating deployments. Feedback on ease of use, clarity of interface, and overall user satisfaction will be gathered.

Deployment Scenario Testing: Various deployment scenarios will be rigorously tested, including:

Successful deployments of different metadata types.

Deployments resulting in partial success (where some components pass and others fail).

Deployments that fail entirely (e.g., due to validation errors in the target org, test failures, or API issues).

Testing of specific deployment options like checkOnly and different testLevel values.

Status Reporting Verification: Confirmation that real-time status updates are accurately displayed in the LWC and that the final status (success/failure) is correctly reflected.

Audit Trail Confirmation: Verification that Deployment__c records are accurately created and updated with all relevant details, including User_Comments__c and Deployment_Log__c, providing a comprehensive audit trail for each deployment.

 

8. Future Enhancements and Roadmap
 

The Declarative Metadata Deployer is designed as a foundational tool. Several enhancements can be considered for future development to further extend its capabilities and integrate it more deeply into 8squad's DevOps practices.

 

8.1. Deployment History and Comprehensive Audit Logs
 

Expanded Logging: Enhance the Deployment_Log__c field or introduce a new custom object (e.g., Deployment_Component_Log__c) to capture more granular details. This would include component-level success or failure messages, specific error details from the Metadata API's DeployResult.details.componentFailures , and detailed timestamps for each stage of the deployment process.

Dedicated History Tab: Develop a dedicated LWC tab or page for viewing historical deployments. This interface would allow users to easily search, filter, and sort past deployments, providing quick access to audit trails and troubleshooting information.

 

8.2. Rollback/Undo Functionality
 

Backup Storage: Implement a mechanism within the External Deployment Engine to automatically store a backup of the retrieved metadata ZIP files (or source-formatted metadata) before initiating a deployment to the target organization. This backup would represent the state of the components just prior to the change.

Rollback Mechanism: Develop a feature that allows users to initiate a "rollback" or "undo" operation. This would involve the External Deployment Engine re-deploying the stored backup or a previous version of the components to revert the changes made by a failed or erroneous deployment. This significantly enhances operational resilience and reduces the impact of deployment issues.

 

8.3. Advanced Component Type Filtering and Search
 

Granular Filtering: Extend the LWC's search capabilities to allow users to filter by more specific metadata attributes. For example, filtering Apex Classes by their status (e.g., Active, Inactive), Flows by their version status (e.g., Active, Inactive, Draft), or Custom Objects by their sharing model.

Sophisticated Search: Implement more advanced search capabilities, such as support for regular expressions (regex) or full-text search within the metadata content itself (if the External Deployment Engine retrieves and makes this content searchable). This would enable highly specific searches for code patterns or configuration details.

 

8.4. Integration with Commercial DevOps Tools or Salesforce DevOps Center
 

While the Declarative Metadata Deployer is a valuable custom solution addressing specific pain points related to Change Sets, it is important to acknowledge the broader landscape of Salesforce DevOps. Commercial DevOps tools (e.g., Copado, Gearset, AutoRABIT, Blue Canvas) offer a comprehensive suite of capabilities that extend far beyond simple deployments, including full CI/CD pipelines, robust version control integration, advanced impact analysis, automated testing frameworks, multi-cloud support, and sophisticated release management features. Salesforce's own DevOps Center is also an evolving native offering.

The custom tool fills a specific gap where existing processes or commercial tools might be perceived as insufficient or overly complex for certain ad-hoc or simplified deployment needs. However, as 8squad's DevOps maturity evolves, a natural progression would involve integrating this custom tool with, or potentially migrating to, a more comprehensive commercial DevOps platform or Salesforce DevOps Center. Such integration would provide greater long-term benefits, reduce the overhead of maintaining a custom deployment solution, and enable a more holistic approach to software delivery lifecycle management for Salesforce. This strategic consideration demonstrates foresight beyond the immediate project scope, positioning the Declarative Metadata Deployer as a stepping stone towards a more mature DevOps ecosystem.

 

9. Conclusion
 

The Declarative Metadata Deployer represents a strategic advancement for 8squad's Salesforce operations. This comprehensive engineering and solution design outlines a user-friendly, declarative tool that significantly improves the efficiency and reliability of metadata deployments, directly addressing the frustrations associated with traditional Change Sets.

The robust architectural decisions, including the clear separation of concerns between Salesforce Org A and an external middleware, the reliance on asynchronous processing, and the implementation of secure authentication via Named Credentials and JWT Bearer Flow, ensure a scalable, secure, and maintainable solution. The meticulous design of custom objects for auditability, coupled with advanced LWC features like infinite scrolling and server-side filtering, guarantees a performant and intuitive user experience even with large volumes of metadata.

Furthermore, the detailed planning for error handling, retry mechanisms, and comprehensive logging establishes a resilient deployment process, minimizing manual intervention and providing critical insights for troubleshooting. While designed for immediate internal impact, the identified roadmap for future enhancements, including comprehensive audit logs, rollback capabilities, and potential integration with commercial DevOps platforms, positions this solution as a strategic asset. It lays a solid foundation for continuous improvement in 8squad's DevOps maturity, empowering a broader range of users to contribute effectively to Salesforce development and release management.

Sources used in the report


trailhead.salesforce.com

Get metadata of multiple Workflows in single callout using Tooling API in Apex - Trailhead

 Opens in a new window


developer.salesforce.com

Check the Status of Your Deployment Using REST Resources | Metadata API Developer Guide

 Opens in a new window


developer.salesforce.com

DeployResult Class | Apex Reference Guide - Salesforce Developers

 Opens in a new window


youtube.com

Retrieve Salesforce Deployment Status Details using Rest Resources - YouTube

 Opens in a new window


developer.salesforce.com

Deploy Metadata with Apex Testing Using REST - Salesforce Developers

 Opens in a new window


developer.salesforce.com

deploy() | Metadata API Developer Guide

 Opens in a new window


salesforce.stackexchange.com

callout - Has anyone, ever, successfully invoked the Metadata API from within Apex?

 Opens in a new window


resources.docs.salesforce.com

Tooling API - Salesforce

 Opens in a new window


sfdcblogs.com

Salesforce Callout Best Practices: A Complete Guide for Developers

 Opens in a new window


twopirconsulting.com

Best Practices for Apex Class External Callouts in Salesforce - Twopir Consulting

 Opens in a new window


devcenter.heroku.com

Integrating Heroku and the Salesforce Platform Overview

 Opens in a new window


trailhead.salesforce.com

How to retry the callout on http | Salesforce Trailblazer Community

 Opens in a new window


heroku.com

Reactive Programming with Salesforce Data | Heroku

 Opens in a new window


cciedump.spoto.net

Free Salesforce ARC?201 Practice Exam | SPOTO

 Opens in a new window


medium.com

10 core strategies for safe REST API callouts in Apex | by Harshit Gupta | Jul, 2025 - Medium

 Opens in a new window


help.salesforce.com

Set Up Retry Policies for Failed Callouts - Salesforce Help

 Opens in a new window


medium.com

The Shortcut to Smart Pagination in Salesforce via SOQL | by Shah Bhumi | Medium

 Opens in a new window


heroku.com

Heroku AppLink: Extend Salesforce with Any Programming Language

 Opens in a new window


developer.salesforce.com

Deploying and Retrieving Metadata | Metadata API Developer Guide

 Opens in a new window


partners.salesforce.com

Heroku - Salesforce Partner Community

 Opens in a new window


salesforce.stackexchange.com

Apex equivalent of REST api's nextRecordsUrl - Salesforce Stack Exchange

 Opens in a new window


developer.salesforce.com

CustomObject | Metadata API Developer Guide

 Opens in a new window


medium.com

Lightning Data Table with Pagination-LWC | by Salesforce Insight - Medium

 Opens in a new window


medium.com

Lightning Data Table with Search Bar-LWC | by Salesforce Insight - Medium

 Opens in a new window


crsinfosolutions.com

How to use Tooling API in Apex? - CRS Info Solutions

 Opens in a new window


developer.salesforce.com

JSON Parsing | Apex Developer Guide

 Opens in a new window


sf9to5.com

How to Parse JSON using APEX - sf9to5

 Opens in a new window


medium.com

Deploy a Custom Object and Fields in a Salesforce Org using meta data API - Medium

 Opens in a new window


vimera.io

Optimizing Salesforce lightning web components for performance and scalability - Vimera

 Opens in a new window


apexhours.com

Lazy loading in Lightning Web Component - Apex Hours

 Opens in a new window


techdicer.com

Keep Selected Rows in LWC Datatable Pagination - Techdicer

 Opens in a new window


youtube.com

Infinite Loading with Datatable in LWC - YouTube

 Opens in a new window


developer.salesforce.com

Display Data in a Table with Inline Editing | Work with Salesforce Data | Lightning Web Components Developer Guide

 Opens in a new window


thectoclub.com

16 Best DevOps Tools For Salesforce Reviewed In 2025 - The CTO Club

 Opens in a new window


salesforce.com

Best DevOps Tools and Platform | Salesforce DevOps Center

 Opens in a new window


trailhead.salesforce.com

ApexREST and NextRecordsURL | Salesforce Trailblazer Community - Trailhead

 Opens in a new window


help.salesforce.com

Object Relationships Overview - Salesforce Help

 Opens in a new window


salesforce.stackexchange.com

Tooling API in Apex - polymorphism, generic query() callout? - Salesforce Stack Exchange

 Opens in a new window


developer.salesforce.com

CustomField | Metadata API Developer Guide

 Opens in a new window


apexhours.com

Salesforce OAuth 2.0 JWT Bearer flow - Apex Hours

 Opens in a new window


help.salesforce.com

Metadata API Edit Access - Salesforce Help

 Opens in a new window


developer.salesforce.com

PermissionSet | Metadata API Developer Guide