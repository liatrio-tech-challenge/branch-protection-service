# Infrastructure
The terraform config in this directory will set up an Azure function to host the branch protection service, 
and sets up an organization webhook to notify the service when a new repo is created.

### Prerequisites
* An Azure subscription
* A service principle with Contributor access to the subscription
* A storage account with a container for state in the subscription
* A GitHub org
* An arbitrary shared secret

#### Secrets for workflow
The following secrets need to be configured for the terraform plan and apply workflows to work:
* Service principle secrets:
  * ARM_CLIENT_SECRET
  * ARM_CLIENT_ID
  * ARM_SUBSCRIPTION_ID
  * ARM_TENANT_ID
* GitHub PAT for creating webhook:
  * ORG_HOOK_PAT
    * (only needs `admin:org_hook` permission)
* Shared secret for webhook:
  * WEBHOOK_SECRET
    * (can be anything)