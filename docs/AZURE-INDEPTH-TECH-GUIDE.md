This is a quick quide on how get started with the Azure Proxy Function. Before starting with anything please make sure that all tools, CLIs  are installed on your machine and your own Azure Subscription. Install/purchase 
all things from this list:
1. [Azure Subscription](https://azure.microsoft.com/en-us/free/) - Purchase new Subscription if you don't have any. When this is done go to [Azure Portal](https://portal.azure.com) sign in with your credentials and go to the [Azure Subscription Blade](https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade). If you see subscriptions in the list than your are good to go. Example: ![alt text](./StaticFiles/SubscriptionBlade.png)
2. Download and Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli). Choose your OS type and follow the instructions. After you are done with this step go ahead and check if the CLI is installed by opening the terminal and type this command: ``` az --version```. The output should look like this: ```azure-cli                         2.0.81``` where version 2.0.81 is the current version of the moment of this writting. If you get any version than everything is ok
3. Download and Install [Func Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=v3%2Cwindows%2Ccsharp%2Cportal%2Cbash%2Ckeda#install-the-azure-functions-core-tools) version 3. Choose your OS type and follow the instructions. After everything is completed go ahead and check if the Func Core Tools are installed by opening the terminal and type this command: ```func --version```. Sample output: ```3.0.3734```. Major version should be 3.
4. Download and Install [Terraform cli](https://www.terraform.io/downloads.html). Choose your OS type and read the user manual on the terraform site. Please make sure that the terraform executable is added to your OS env variables. Go to [this page](https://superuser.com/questions/284342/what-are-path-and-other-environment-variables-and-how-can-i-set-or-use-them) to see how to do that for your OS. After everything is done make sure that terraform CLI is installed by opening the terminal and type this command: ```terraform --version```. Sample output should be ```Terraform v1.0.7
on linux_amd64```. This sample is for Linux OS with AMD64. Depending on you OS type that may change but there should be Terraform version output like ```Terraform v1.0.7``` if everything is ok.
5. Download and install [VS Code](https://code.visualstudio.com/download). Choose your OS type. When everything is done make sure that VS Code is installed by opening the terminal and type this command ```code .```. If new VS Code window is opened then everything is ok.
6. Download and install [Git](https://git-scm.com/downloads). Choose your OS type. When everything is done make sure that git is installed by opening the terminal and type this command ```git --version```. Sample output: ```git version 2.33.0```. If there is a git version in the output then everything is good.


After all tools are here go ahead and clone the repo and navigate to the correct branch by using this commands from the terminal:
```git clone https://github.com/blamelesshq/prometheus-lambda.git```
```git checkout -b develop-petar```
```git pull origin develop-petar```

Now when you have the code go ahead to the clone directory root folder and open the folder in VS Code by typing this command from the terminal:
```code .``` 
You should see this folder structure in VS Code. ![alt text](./StaticFiles/VsCodePrometheus.png) 

Now that we have the code base and tools locally, and we have our own Azure Subscription next phase is to create all needed resources on Azure. That will be done using terraform. Before doing that let's give a short description about Azure resources.

1. First resource that needs to be created is Resource Group. **(Required Resource!)**
All resources in Azure are organized and placed in a container called [resource group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group). This container and all other azure resources (objects) need to be placed in a certain Geographic Location called [regions](https://docs.microsoft.com/en-us/azure/availability-zones/az-overview). So the first resource that we need to create in Azure is Resource Group where all other resources will be put in. 
In order to do that with terraform, proper terraform script should be defined. 

In a specific [providers.tf file](./deploy/azure/resourceGroup/providers.tf) the specific version of terraform provider is described.

Current version is specified in the file
```
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.83.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```
Same version is specified in all other terraform modules as well.

Please navigate to the [Resource Group Terraform script](./deploy/azure/resourceGroup/main.tf) to see the main script. 

In the first section of the script:
```
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
```
the actual resource group is defined. Name of the resource group (that should be unique in your Azure Subscription) and geographical location are defined in the [variables.tf](./deploy/azure/resourceGroup/variables.tf) file and they are both of type string. At the end after the execution of the terraform script newly created resource group id (guid) and resource group name are needed. That's why they are defined in [outputs.tf](./deploy/azure/resourceGroup/outputs.tf) file.

2. Azure Function App **(Required Resource!)**
[Azure Function App](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview) is a collection of one or more functions that are managed together. All functions in the function app share the same pricing plan which can be [Consumption plan](https://docs.microsoft.com/en-us/azure/azure-functions/consumption-plan), [Premium plan](https://docs.microsoft.com/en-us/azure/azure-functions/functions-premium-plan?tabs=portal) or [Dedicated plan](https://docs.microsoft.com/en-us/azure/azure-functions/dedicated-plan). Mainly Azure Functions are serverless solution that allows you to write less code, maintain less infrastructure, and save on costs.
In order to create Azure Function App using Terraform script couple of things needed to be specified.

First thing that need to be created is Azure Storage Account. This is required for Azure Function App. For more info why this is needed go to [Azure Function App Storage Account page](https://docs.microsoft.com/en-us/azure/azure-functions/storage-considerations). In our case this is the terraform section that does this:
```
resource "azurerm_storage_account" "funcdeploy" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
}
```
```name``` - is storage account name which need to be globally unique. Variable for that is defined in [variables.tf](./azure/deploy/function/variables.tf) file. Find more info [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#name).
```resource_group_name``` - name of the resource group which is also defined in the [variables.tf](./azure/deploy/function/variables.tf) file. Same resource group name will be used that was created above (resource group section). Find more info [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#resource_group_name)
```location``` - geographic location which is defined in [variables.tf](./azure/deploy/function/variables.tf) file. Find more info [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#location). See all possible values [here](https://github.com/claranet/terraform-azurerm-regions/blob/master/REGIONS.md)
```account_tier``` - Defines tier for storage account and is defined in [variables.tf](./azure/deploy/function/variables.tf) file. For more info go [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#account_tier). Valid options are Standard and Premium.
```account_replication_type``` - Defines Storage account replication type and it's defined in [variables.tf](./azure/deploy/function/variables.tf) file. Find more info [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#account_replication_type) and [here](https://docs.microsoft.com/en-us/azure/storage/common/storage-redundancy). Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS.

Third thing that needs to be created is [storage account blob container](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction) needed for the azure function. That is defined in this section:
```
resource "azurerm_storage_container" "funcdeploy" {
  name                  = "contents"
  storage_account_name  = azurerm_storage_account.funcdeploy.name
  container_access_type = "private"
}
```
```name``` - Container name
```storage_account_name``` - name of the storage account created in above step
```container_access_type``` - Access level on the container. Should be private (doesn't need to be accessable from outside)
More info for container can be found [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_container).

Fourth thing that is specified but it is optional is Application Insights. This resource is for monitoring AzureFunction (both application and system monitor). It's not a must but it is recommended to have. That is defined in this section:
```
resource "azurerm_application_insights" "funcdeploy" {
  name                = var.appinsights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"

  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/1303
  tags = {
    "hidden-link:${var.resource_group_id}/providers/Microsoft.Web/sites/${var.azure_func_name}" = "Resource"
  }

}
```
```name``` - Name of app insights. It's defined in [variables.tf](./azure/deploy/function/variables.tf) 
```location``` - Geographic location (same as above)
```resource_group_name``` - Same as above
```application_type``` - Type of application insights that needed to be created. More info can be found [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights#application_type).
```tags``` - Tags section is optional. It helps us to organize resources better and add better description why they are used. In our case the description is that this app insights instance is used to monitor azure function app with certain id located in certain resource group.

Fifth thing that is specified is App Service Plan. In our example we are using App Service Plan Tier.
```
resource "azurerm_app_service_plan" "funcdeploy" {
  name                = var.functionapp_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = var.sku_tier
    size = var.sku_size
  }
}
```
For name, location, resource_group_name is the same description as above. 
```kind``` - For what are we going to use this AppService Plan instance? More info can be found [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_plan#kind).
```tier``` - Specifies App Service Plan Pricing tier. Find more about tiers [here](https://azure.microsoft.com/en-us/pricing/details/app-service/linux/)
```size``` - this is related to tier size. Each tier can have dirrent size (instance types). More info can be found [here](https://azure.microsoft.com/en-us/pricing/details/app-service/linux/)

Last thing that needs to be created is the actual Azure Function App. That's defined in this section:
```
resource "azurerm_function_app" "funcdeploy" {
  name                       = var.azure_func_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.funcdeploy.id
  storage_account_name       = azurerm_storage_account.funcdeploy.name
  storage_account_access_key = azurerm_storage_account.funcdeploy.primary_access_key
  https_only                 = true
  version                    = "~3"
  os_type                    = "linux"
  # To see this - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app#vnet_route_all_enabled 
  app_settings = {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
      "FUNCTIONS_WORKER_RUNTIME" = "custom"
      "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.funcdeploy.instrumentation_key}"
      "CLOUD_PLATFORM" = "${var.CLOUD_PLATFORM}"
      "PROMETHEUS_PASSWORD" = "${var.PROMETHEUS_PASSWORD}"
      "PROMETHEUS_LOGIN" = "${var.PROMETHEUS_LOGIN}"
      "RESTO_URL" = "${var.RESTO_URL}"
      "PROMETHEUS_URL" = "${var.PROMETHEUS_URL}"
  }


  # Enable if you need Managed Identity
  identity {
    type = "SystemAssigned"
  }
}
```
name, location, resource_group_name, app_service_plan_id, storage_account_name, storage_account_access_key are coming from previously created resources and in this final step we relate them to the actual azure function app. Other sections are:
```https_only``` - Config that enables function app to allow only https traffic
```version``` - Function version which is set up to version 3 in our example
```os_type``` - OS type which is linux in our example.
```app_settings``` - Application environment variables. CLOUD_PLATFORM, RESTO_URL, PROMETHEUS_LOGIN, PROMETHEUS_PASSWORD, CLOUD_PLATFORM are app specific. Other configs - WEBSITE_RUN_FROM_PACKAGE tells that app can be run from zip package (function app), FUNCTIONS_WORKER_RUNTIME (programming runtime. In our case is custom - we are using Go), APPINSIGHTS_INSTRUMENTATIONKEY - application insights that that was created above.
```identity``` - this is enabling managed identity for the function app in order for function to be able to access other Azure Resource securely without going outside of Azure Network. This will be needed in the future for access to the KMS system (Azure Key Vault) from the Function App.

Main terraform script is defined [here](./deploy/azure/function/main.tf), together with the [variables](./deploy/azure/function/variables.tf) and [outputs.tf](./deploy/azure/function/outputs.tf) - variables needed in the next terraform scripts (modules).

3. Azure Key Vault (**OPTIONAL!**)
[Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/basic-concepts) is key management store service in Azure. All sensitive secrets and certificates like connection strings, keys etc that are used in Azure should be stored in key vault. This service is easily integratable with Azure Functions by using [Key Vault references](https://docs.microsoft.com/en-us/azure/app-service/app-service-key-vault-references). Only thing that should be done is to grant access from your Azure Function App to KeyVault using system managed identity (see section ```identity {
    type = "SystemAssigned"
  }```  from Azure Functions part).
  In order to create Azure Key Vault this main [terraform](./deploy/azure/keyvault/main.tf) script is used. All needed terraform required providers are defined in [providers](./deploy/azure/keyvault/providers.tf) file (see above explaination on what providers are). 
  KeyVault terraform script has a few sections:
  ```
  resource "azurerm_key_vault" "keyvault" {
  name                        = var.keyvault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  #soft_delete_enabled         = false
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
      "list",
      "set",
      "delete",
      "purge",
    ]

    storage_permissions = [
      "get",
    ]
  }
  ```
  ```name,location,resource_group_name``` properties are similar as in the Azure Function App script
```enabled_for_disk_encryption``` - Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys
```tenant_id``` - Azure Active directory tenant id. It gets it's value from the current signed in user. To sign in to your subscription this Azure CLI command should be used from the terminal: ```az login```
```soft_delete_retention_days``` - The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days.
```purge_protection_enabled``` - Is Purge Protection enabled for this Key Vault? Defaults to false
```sku_name``` - The Name of the SKU used for this Key Vault. Possible values are standard and premium
```access_policy``` - This section is for setting proper access to the key vault secrets, storage and keys to the current signed in user

Next section is for adding secrets in your key vault. For example:

```
resource "azurerm_key_vault_secret" "PROMETHEUS_URL" {
  name         = "PROMETHEUS-URL"
  value        = var.PROMETHEUS_URL
  key_vault_id = azurerm_key_vault.keyvault.id
}
```

This is for adding secret with name "PROMETHEUS-URL". The value for this secret is defined in [variables](./deploy/azure/keyvault/variables.tf) terraform file. This sample variable is for prometheus azure proxy function. If you need more values you just need to append those values in this terraform script.
4. KeyVaultAccess (**OPTIONAL**. Required if KeyVault is defined)
This terraform script is to add proper access to keyvault for the Azure Function App. As described in the KeyVault and Azure Function App section KeyVault can be directly integrated with Azure Function App using system managed identity. With this [terraform script](./deploy/azure/keyvaultAccess/main.tf) that is achieved with this section:
```
resource "azurerm_key_vault_access_policy" "keyvault" {
  key_vault_id = var.keyvault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.identity_id

  secret_permissions = [
    "Get",
    "List",
  ]
}
```
```key_vault_id``` - is the key vault identifier that 
comes up as a variable (described in [variables.tf](./deploy/azure/keyvaultAccess/variables.tf))
```object_id``` - is object identifier of the Azure Function App Managed Identity (described in [variables.tf](./deploy/azure/keyvaultAccess/variables.tf))
```secret_permissions``` - Azure Function App will have only Get,List permission to the Azure KeyVault secrets.
5. NatGateway (**OPTIONAL**)
Multiple resources are created in this template. Main idea with this is for the Azure Function App to have only one outbound ip address and only that address to be whitelisted on the server (splunk/prometheus) side as an allowed address. Resources created: Virtual Network, Subnet, NatGateway, Virtual Network Connection to the Function App. This is optional since if not created there are multiple outbound address for the function app and all of them need to be whitelisted.
Main terraform script can be find [here](./deploy/azure/natGateway/main.tf)
6. Azure API Management (**OPTIONAL**)
ApiManagement resource that will route traffic to single/multiple proxy function(s). Has single endpoint. It is not required since each proxy function(s) has/have endpoint.
With the first section of the terraform script - 
```
resource "azurerm_api_management" "example" {
  name                = var.apimanagement_name
  resource_group_name = var.resource_group_name
  location            = var.location
  publisher_name      = var.publisher_name
  publisher_email     = var.admin_email
  sku_name            = var.sku_name
}

```
Api Management resource is getting created. Similar to other resources variables are sent from the variables file. 
- ```publisher_name,publisher_email``` can be anything.
- ```sku_name``` - sku_name is a string consisting of two parts separated by an underscore(_). The first part is the name, valid values include: Consumption, Developer, Basic, Standard and Premium. The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer

It is for creating an API within Azure API Management service. To do this an openapi spec is predefined in this [file](./deploy/azure/api-spec.yml).
With the last section:
```
resource "azurerm_api_management_api_policy" "example" {
  api_name            = azurerm_api_management_api.example.name
  api_management_name = azurerm_api_management_api.example.api_management_name
  resource_group_name = var.resource_group_name
```
Main terraform script can be find [here](./deploy/azure/main.tf)
7. Azure API Management Spec Builder (**OPTIONAL**)
This terraform modules takes the content of the route-config.yaml declarative file and builds proper ApiManagement OpenApiSpec based on the functions defined in route-config.yaml file. For more technical details about the tool and how this process is getting done visit [FuncCodeBuilder](./FuncCodeBuilder.md) document.
8. Azure API Management Import (**OPTIONAL**)
After the proper OpenApi spec is build with the previous terraform module (Azure API Management Spec Builder) this terraform module is importing the newly generated OpenApiSpec to the already created AzureApiManagement by using proper Azure CLI command.
9. functionUpdate (**OPTIONAL**)
This terraform module works as an independent module from the [main module](../deploy/azure/main.tf) and only should be used if some code changes are done to the proxy function or when the route-config.yaml file is modified. This module calls the ProxyFuncCodeBuilder tool, makes update to the Function App (delete, add functions based on the changes of the route-config), updates the ApiManagement OpenApiSpec file and deploys Azure Function App and Azure Api Management to apply those changes. As a parameters it is expected to be passed:
- azure_func_name (Azure Function Name)
- key_vault_name (Key Vault Name)
- resource_group_name (Resource group name)
- apimanagement_name (Azure Api Management Name)
- apimanagement_revision (Api Management revision number. Should be autoincrement number of updates).
Navigate to the  [FuncCodeBuilder tool document](./FuncCodeBuilder.md) for more information.
10. functionDeploy (**REQUIRED**)
This module is used together with the main terraform script on the initial creation of the resources. This modules calls the FuncCodeBuilder tool in order to create all functions needed in the FunctionApp based on the functions inserted in the route-config.yaml document and deploys the Azure Function App to azure.

**Conculsion:**
These 10 terraform modules are all connected in one [main.tf](./deploy/azure/main.tf) terraform script. All variables for the main terraform script is defined in [variables.tf](./deploy/azure/variables.tf) file. Actual values for the variables can be finded in [terraform.tfvars](./deploy/azure/terraform.tfvars)


In order to execute current terraform scripts you need to navigate to this "./deploy/azure/" directory via terminal and follow these steps by using Terraform CLI:
1. terraform init (find more info [here](https://www.terraform.io/docs/cli/commands/init.html))

**Example:**
![alt text](./StaticFiles/terraformInit.png)

2. terraform plan -out tfplan (find more info [here](https://www.terraform.io/docs/cli/commands/plan.html)), where tfplan is terraform plan name (can be anything)

**Example:**
![alt text](./StaticFiles/terraformPlan.png)

3. terraform apply tfplan --var-file="terraform.tfvars" (find more info [here](https://www.terraform.io/docs/cli/commands/apply.html))

**Example:**
![alt text](./StaticFiles/terraformApply.png)

For more info about how to create Azure resources with terrafom go to this [page](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs).



At the end when all terraform resources are created Azure Proxy Function should be deployed. One way of how to deploy Azure Function is to use Azure Function Core Tools. First, you need to navigate to your Azure Function directory (in our example if it is Splunk it's under './Splunk' directory) and execute this command:
```func azure functionapp publish <function-app-name>``` 
where "function-app-name" (placeholder in the example) is the name of your function app. Prerequisite for doing this is to be logged in to your Azure Subscription using azure CLI.

If everything wents ok then the these Azure resources should be created:
![alt text](./StaticFiles/AzureResources.png)
In this example the names as shown including "blameless prometheus" words but that can be anything based on the values inserted in .tfvars config file.