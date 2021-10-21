# Lambda function for Prometheus

AWS and GCP integration for fetch data from Prometheus

### Clouds
This repo contains a common function for AWS and GCP. We have some differences between AWS and GCP:
1. AWS uses binary for deploy;
2. GCP uses source code for deploy;
3. GCP uses a package. The package name must not be `main`;
4. GCP uses go.mod or vendor (go modules).


### Terrafrom
This repo contains two terraform script for AWS and GCP.

#### AWS resources:
1. Lambda;
2. API getaway;
3. KMS keys.

#### GCP resources:
1. Google Run;
2. Google Endpoints;
3. Google Function;
4. Google Bucket.

### Deploy:
1. Set env variables in `.env` file;
2. Run `source .env` to set environment; 
3. Run `make` to build a docker container;
4. Run `make deploy` for deploy to a cloud and choose cloud `AWS` or `GCP`;
5. Next: [Instruction for GCP](#GCP) \ [Instruction for AWS](#AWS).

#### GCP:
1. Set the major version;
2. Set the minor version (update each deploy to avoid deployment errors);
3. Set project name;
4. Set region deployment.

#### AWS:
1. Set API name. It will use as part of a path URL;
2. Set region for deployment.

#### Azure:
1. Modify terraform.tfvars file with your values for Azure Resources and prometheus/splunk server url

Azure terraform scripts are split into 6 modules for creation of the resources.
- [ResourceGroup](./deploy/azure/resourceGroup)
 -> Azure resource group where all resources need to be placed
- [Function](./deploy/azure/function)
 -> Azure Function App where the proxy function(s) will be placed
- [ApiManagement](./deploy/azure/apiManagement) (optional)
 -> ApiManagement resource that will route traffic to single/multiple proxy function(s). Has single endpoint. It is not required since each proxy function(s) has/have endpoint.
- [KeyVault](./deploy/azure/keyvault) (optional)
 -> Secure key management service that is Azure Specific. All secrets needed for Azure Proxy Function(s) should be stored here (like ConnectionStrings, Passwords, Credentials). These secrets can be stored as an environment variables on Azure Function App as well which is why this is an optional resource
- [KeyVaultAccess](./deploy/azure/keyvaultAccess) (optional)
 -> Access policy between keyvault and Azure Function App. If KeyVault is not created than this is optional
- [NatGateway](./deploy/azure/natGateway) (optional)
 -> Multiple resources are created in this template. Main idea with this is for the Azure Function App to have only one outbound ip address and only that address to be whitelisted on the server (splunk/prometheus) side as an allowed address. Resources created: Virtual Network, Subnet, NatGateway, Virtual Network Connection to the Function App. This is optional since if not created there are multiple outbound address for the function app and all of them need to be whitelisted.

All optional modules can be commented out from the [main](./deploy/main.tf) terraform file if not used