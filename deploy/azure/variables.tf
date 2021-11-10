# General
variable "resource_group_name" {
  type        = string
  description = "Resource Group Name in Azure"
}

variable "location" {
    type        =   string
    description = "Resources Location"
}

# KeyVault
variable "keyvault_name" {
  type        = string
  description = "Key Vault Name in Azure"
}

variable "RouteConfig" {
  type        = string
  description = "RouteConfig"
}

# variable "SPLUNK_URL" {
#     type        =   string
#     description = "SPLUNK_URL"
# }

# variable "SPLUNK_ACCESS_TOKEN" {
#     type        =   string
#     description = "SPLUNK_ACCESS_TOKEN"
# }

# variable "PROMETHEUS_URL" {
#     type        =   string
#     description = "Prometheus Server URL Configuration"
# }

# variable "RESTO_URL" {
#     type        =   string
#     description = "Resto URL"
# }

# variable "PROMETHEUS_LOGIN" {
#     type        =   string
#     description = "Resto Login"
# }

# variable "PROMETHEUS_PASSWORD" {
#     type        =   string
#     description =   "Prometheus server password (if any)"
# }

#AzureFunction
variable "sku_tier" {
    type        =   string
    description = "Azure function SKU"
}

variable "sku_size" {
    type        =   string
    description = "Azure function SKU Size"
}

variable "functionapp_name" {
    type        =   string
    description = "Azure Function Name"
}

variable "appinsights_name" {
    type        =   string
    description = "Azure Application Insight Instance Name (connected with Azure Function)"
}

variable "storage_account_name" {
    type        =   string
    description = "Azure Storage Account Name (needed for the Azure Function)"
}

variable "storage_account_tier" {
    type    =   string
    description = "Azure Storage Account Tier (needed for the Azure Function)"
}

variable "storage_account_replication_type" {
    type    =   string
    description = "Azure Storage Account Replication Type (needed for the Azure Function)"
}

variable "CLOUD_PLATFORM" {
    type        =   string
    description = "Cloud Platform env variable needed for the Azure Function Logic"
}

variable "azure_func_name" {
    type        =   string
    description =   "Azure Func Name"
    default     =   "blamelessprometheusfunc"
}


# ApiManagement
variable "apimanagement_name" {
    type    =   string
    description = "Azure API Management name"
}

variable "publisher_name" {
    type = string
    description = "Azure API Management Publisher Name"
}

variable "admin_email" {
    type    =   string
    description = "Azure API Management Admin Email"
}

variable "sku_name" {
    type    =   string
    description = "Azure API Management Sku Name"
    default = "Consumption_0"
}

variable "apimanagement_display_name" {
    type    =   string
    description = "Azure API Management display name"
}

variable "nat_location" {
    type        =  string
    description = "NAT Location"
}