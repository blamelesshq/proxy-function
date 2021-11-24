# Blameless Proxy function - Deployment Guide for Azure

Deployment Guide for the Blameless Proxy function in Azure

| Project          | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| Status           | Early Access phase (alpha)                                   |
| Content          | This project provides a Terraform script with 10 Terraform modules to configure and deploy the required cloud infrastructure in Azure and the Blameless proxy function. |
| Deployment steps | 1. Deploy all necessary Azure resources in one single Terraform command.

For more tech detail description on the deployment go to  [AZURE-INDEPTH-TECH-GUIDE](./AZURE-INDEPTH-TECH-GUIDE.md) document and [FuncCodeBuilder](./FuncCodeBuilder.md) documents.

## PREREQUISITES

To deploy the Blameless proxy function in Azure, you need the following prerequisites:

1. An **Azure account** using an **Azure subscription** and an **Azure user account** with the appropriate permissions to deploy the required Azure resources (see list of [Azure resources types](#deploy-the-infrastructure-to-azure) mentioned further below).
2. **Blameless account** (instance) with at least a **Blameless user account**, to connect Blameless to your Blameless proxy functions deployed in your Azure account.



## REQUIRED TOOLS

The following table describes the list of tools you need to install on your local machine to be able to deploy the cloud infrastructure in Azure needed to operate your Blameless proxy functions. 

| Tool               | Tested versions                    | Version checking        |
| ------------------ | ---------------------------------- | ----------------------- |
| Azure CLI          | 2.29.1                             | `$ az --version`        |
| Func Core Tools    | 3.0.3904                           | `$ func --version`      |
| Terraform CLI      | v1.0.10                            | `$ terraform --version` |
| Git                | git version 2.30.1 (Apple Git-130) | `$ git --version`       |
| Visual Studio Code | Latest                             |                         |



### Azure CLI

Make sure you are logged in to the Azure

```shell
$ az login
```

### Terraform
Download Terraform CLI binary from here: https://www.terraform.io/downloads.html 

Move the Terraform binary to a path defined in your environment variable PATH

```shell
$ mv ~/Downloads/terraform /usr/local/bin

$ which terraform
/usr/local/bin/terraform
```



## INSTALLATION

### Clone this repository

```shell
$ git clone https://github.com/blamelesshq/proxy-function.git
```

> Note: The repository is still private and will require you to provide a Github user name to provide you access to it.

### Deploy the infrastructure to Azure

The provided Terraform modules allows you to install the following Cloud infrastructure resources in Azure to securely run your Blameless Proxy functions:

| #    | Azure Resource Type | Description                                                  |
| ---- | ------------------- | ------------------------------------------------------------ |
| 1    | Resource Group      | Unique name to group all these resources in Azure            |
| 2    | Function App        | Host the the Blameless proxy function                        |
| 3    | Function App (functionDeploy)       | Deploy Function App after it is created                        |
| 4    | Function App (functionUpdate)       | Deploy Function App and API Management after the function is updated                        |
| 5    | Key Vault           | Securely holds the credentials allowing a Blameless proxy function to connect to its target metric server |
| 6    | Key Vault Access    | Required and deployed along with the Azure Key Vault resource |
| 7    | API Management      | Routes HTTP traffic from your Blameless account to the appropriate Azure function. |
| 8    | API Management (apiManagementSpecBuilder)     | Creates api management OpenApi Spec file based on route-config for the proxy function(s). |
| 9    | API Management (apiManagementImport)     | Imports newly created OpenApi spec on already created Azure API Management instance |

Optional Azure resources:

| #    | Azure Resource Type | Description                                                  |
| ---- | ------------------- | ------------------------------------------------------------ |
| 10    | NAT Gateway         | Provides a single outbound IP address (behind a NAT Gateway), optionally needed to simplify any firewall rules (whitelist ingress IP address) that would be needed to allow the Blameless proxy function to send HTTP GET requests to the target metric server. |



#### Deployment configuration

There 3 key Terraform files at the root of the directory [./deploy/azure](https://github.com/blamelesshq/proxy-function/tree/master/deploy):

| File             | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| main.tf          | All 6 Terraform modules are all connected from the main.tf Terraform script which defines all the resources to be created in Azure. |
| variables.tf     | All variables for the main terraform script                  |
| Terraform.tfvars | Actual values for the variables (specific to each deployment) |



#### Customize your configuration file (terraform.tfvars)

> Note: The main Terraform script deploys only one instance of each Azure resource type (alpha 1.0)

Go to the following **Terraform configuration file** and modify ALL values:

[./deploy/azure/terraform.tfvars](https://github.com/blamelesshq/proxy-function/blob/master/deploy/azure/terraform.tfvars)

**IMPORTANT NOTE**

1. Before you deploy, you MUST set ALL values defined in the Terraform configuration file to match with your specific deployment scenario (Azure region, resource group name, etc.).
2. Make sure to modify all values before you deploy. The default values provided in the original Terraform file are just examples.
3. Some of the names must be unique, and some are globally unique (see note 1)
4. If you don’t provide unique values, Terraform will report an error and you should modify the name again in the Terraform configuration file and try the deployment again.



**Description of all the variables contained in the configuration file:**

| *Variable*                       | *Description*                                                |
| -------------------------------- | ------------------------------------------------------------ |
| **GENERAL RESOURCE GROUP**       | -                                                            |
| resource_group_name              | Unique resource name                                         |
| location                         | Azure region where you intend to deploy this infrastructure (see [Azure regions](https://azure.microsoft.com/en-us/global-infrastructure/geographies/#geographies)) |
| **KEY VAULT**                    | -                                                            |
| keyvault_name                    | Unique key vault name (note 1)                               |
|                                  | ***if connecting the Blameless proxy function to a Splunk endpoint:*** |
| RouteConfig                       | Placeholder. Need to be empty string at the beginning. "functionDeploy" module will update the value.                 |
| **AZURE FUNCTION**               | -                                                            |
| sku_tier                         | Azure function SKU tier (e.g. “Standard”)                    |
| sku_size                         | Azure SKU size (e.g. S1)                                     |
| functionapp_name                 | Unique name of the Azure Function App (note 1)               |
| appinsights_name                 |                                                              |
| storage_account_name             | Azure storage account name (note 1)                          |
| storage_account_tier             | Azure storage account tier (e.g. Standard)                   |
| storage_account_replication_type | "LRS" (default)                                              |
| CLOUD_PLATFORM                   | "Azure" (default)                                            |
| azure_function_name              | Unique name you want to provide to the **Blameless proxy function** (itself) to be deployed inside the Azure Function App (note 2) |
| **API MANAGEMENT**               | -                                                            |
| apimanagement_name               | Unique name for the API Management services (note 1)         |
| publisher_name                   | "Blameless" (default)                                        |
| admin_email                      |                                                              |
| sku_name                         | SKU name for API Management service (e.g. Consumption_0)     |
| apimanagement_display_name       | "Blameless" (default)                                        |





### Deploy your Azure resources and BlamelessProxyFunction using Terraform

Go to the root of the Terraform configuration files:

```shell
$ cd ./deploy/azure
```

Initialize your working directory containing your Terraform configuration files

```shell
$ terraform init
```

Create your execution plan

```shell
$ terraform plan -out tfplan
```

Deploy your Azure resources per the execution plan

```shell
$ terraform apply --var-file="terraform.tfvars" -auto-approve
```

Remove ALL resources from Azure (optional)

```shell
$ terraform destroy
```



To learn more about deploying resources to Azure using Terraform

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs 



### Deploy the Blameless proxy function

The following instructions recommend leveraging the [Azure Function Core tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local) (Azure function CLI) to deploy the Blameless proxy function.

First, capture the name of the function you specified in the Terraform configuration file (terraform.tfvars):

| Terraform variable  |                                                              |
| ------------------- | ------------------------------------------------------------ |
| azure_function_name | Replace <function-app-name> with your Azure function name in the following func command |



Make sure to be logged in to Azure (*)

```shell
$ az login
```

> It opens your web browser to complete a secure login to Azure.

Go to the root of this project

```shell
$ ls
Prometheus		README-Splunk.md	README.md		Splunk			StaticFiles		deploy
```


#### Deploy a Blameless proxy function for Prometheus

Go to the /Prometheus directory

```shell
$ cd ./Prometheus
```

Compile the main.go function (Linux):

```shell
$ env GOOS=linux GOARCH=amd64 go build main.go
```

Deploy the Blameless proxy function

```shell
$ func azure functionapp publish <function-app-name>
```

> Make sure to replace <function-app-name> with the name of the function your provided in the Terraform configuration file (see `azure_function_name`)





== END OF DOCUMENT ==


