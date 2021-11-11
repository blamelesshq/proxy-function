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

variable "location" {
  type        = string
  description = "RG location in Azure"
}

# variable "nat_location" {
#   type        = string
#   description = "Location in Azure"

# #   validation {
# #       condition = contains(["eastus", "eastus2", "southcentralus", "brazilsouth", "canadacentral", "westus2", "westus3", "francecentral", "germanywestcentral", "northeurope", "norwayeast", "uksouth", "westeurope", "southafricanorth", "australiaeast", "centralindia", "japaneast", "koreacentral", "southeastasia", "eastasia"], var.nat_location)
# #       error_message = "The nat location value must be one of these values: eastus, eastus2, southcentralus, brazilsouth, canadacentral, westus2, westus3, francecentral, germanywestcentral, northeurope, norwayeast, uksouth, westeurope, southafricanorth, australiaeast, centralindia, japaneast, koreacentral, southeastasia, eastasia!"
# #   }
# }