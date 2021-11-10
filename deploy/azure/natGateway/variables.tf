variable "location" {
    type    =   string
    description = "Azure Region Location"
}

variable "resource_group_name" {
    type    =   string
    description = "Azure Resource Group Name"
}

variable "natGateway_name" {
    type    =   string
    description = "Azure NAT Gateway name"
}

variable "vnet_name" {
    type    =   string
    description = "Azure Virtual Machine name"
}

variable "subnet_name" {
    type    =   string
    description = "Azure Subnet name"
}

variable "public_ip_name" {
    type    =   string
    description = "Azure Public Ip name"
}


variable "subnet_delegation_name" {
    type    =   string
    description = "Azure Subnet Delegation name"
}

variable "app_service_id" {
    type    =   string
    description = "Azure App Service identifier"
}

variable "availability_zones_regions" {
  type    = list(string)
  default = ["eastus", "eastus2", "southcentralus", "brazilsouth", "canadacentral", "westus2", "westus3", "francecentral", "germanywestcentral", "northeurope", "norwayeast", "uksouth", "westeurope", "southafricanorth", "australiaeast", "centralindia", "japaneast", "koreacentral", "southeastasia", "eastasia"]
}