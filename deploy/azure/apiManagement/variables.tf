variable "location" {
    type    =   string
    description = "Azure Region Location"
}

variable "resource_group_name" {
    type    =   string
    description = "Azure Resource Group Name"
}

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
    default = "admin@example.com" 
}

variable "sku_name" {
    type    =   string
    default = "Consumption_0"
}

variable "apimanagement_display_name" {
    type    =   string
    description = "Azure API Management display name"
}

variable "azure_func_name" {
    type    =   string
    description = "Azure Function Name"
}