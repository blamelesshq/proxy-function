variable "azure_func_name" {
    type        =   string
    description = "Azure Function Name"
}

variable "key_vault_name" {
  type        = string
  description = "Key Vault Name in Azure"
}

variable "resource_group_name" {
    type    =   string
    description = "Azure Resource Group Name"
}

variable "apimanagement_name" {
    type    =   string
    description = "Azure API Management name"
}

variable "apimanagement_revision" {
    type    =   string
    description = "Azure API Management revision"
}