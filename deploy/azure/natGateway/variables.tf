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