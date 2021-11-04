variable "resource_group_name" {
  type        = string
  description = "Resource Group Name in Azure"
}

variable "location" {
    type        =   string
    description =   "Resources Location"
    default     =   "westeurope"
}

variable "sku_tier" {
    type        =   string
    description =   "Azure function SKU"
    default     =   "Dynamic"
}

variable "sku_size" {
    type        =   string
    description =   "Azure function SKU Size"
    default     =   "Y1"
}

variable "functionapp_name" {
    type        =   string
    description = "Azure Function Name"
    default     = "fa-blameless-prometheus"
}

variable "appinsights_name" {
    type        = string
    description = "Azure Application Insight Instance Name (connected with Azure Function)"
    default     = "ai-blameless-prometheus"
}

variable "storage_account_name" {
    type        =  string
    description = "Azure Storage Account Name (needed for the Azure Function)"
    default     = "stblamelessprometheus"
}

variable "storage_account_tier" {
    type        =   string
    description = "Azure Storage Account Tier (needed for the Azure Function)"
    default     =   "Standard"
}

variable "storage_account_replication_type" {
    type        =   string
    description = "Azure Storage Account Replication Type (needed for the Azure Function)"
    default     =   "LRS"
}

variable "CLOUD_PLATFORM" {
    type        =   string
    description = "Cloud Platform env variable needed for the Azure Function Logic"
    default     =   "Azure"
}

# variable "SPLUNK_URL" {
#     type        = string
#     description = "SPLUNK_URL"
# }

# variable "SPLUNK_ACCESS_TOKEN" {
#     type        = string
#     description = "SPLUNK_ACCESS_TOKEN"
# }

variable "RouteConfig" {
    type        = string
    description = "RouteConfig"
}

# variable "PROMETHEUS_URL" {
#     type        = string
#     description = "Prometheus Server URL Configuration"
#     default     = "http://prometheus23092021.westeurope.azurecontainer.io:9090/"
# }

# variable "RESTO_URL" {
#     type        =   string
#     description = "Resto URL"
#     default     =   ""
# }

# variable "PROMETHEUS_LOGIN" {
#     type        =   string
#     description = "Resto Login"
#     default     =   ""
# }

# variable "PROMETHEUS_PASSWORD" {
#     type        =   string
#     description =   "Prometheus server password (if any)"
#     default     =   ""
# }

variable "azure_func_name" {
    type        =   string
    description =   "Azure Func Name"
    default     =   "blamelessprometheusfunc"
}

variable "resource_group_id" {
    type        =   string
    description =   "Azure Resource Group Id"
}

