variable "location" {
    type    =   string
    default =   "West Europe"
}


variable "resourceGroupName" {
    type    =   string
    description = "resourceGroupName"
}


variable "collectionname" { 
    type    =   string
    default = "someone-testing-apim" 
}

variable "publisherName" { 
    type    =   string
    default = "PublisherName" 
}

variable "adminemail" {
    type    =   string
    default = "admin@example.com" 
}

variable "skuName" {
    type    =   string
    default = "Consumption_0"
}

variable "apiManagementName" {
    type    =   string
}

variable "azureFunctionHostname" {
    type    =   string
}

variable "azureFunctionName" {
    type    =   string
}