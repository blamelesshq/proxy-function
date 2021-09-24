variable "location" {
    type    =   string
    default =   "westeurope"
}

variable "prefix" {
    type    =   string
    default =   "210920211"
}

variable "skuTier" {
    type    =   string
    default =   "Dynamic"
}

variable "skuSize" {
    type    =   string
    default =   "Y1"
}

variable "functionAppName" {
    type    =   string
    default =   "functions-consumption-asp"
}

variable "appInsightsName" {
    type    =   string
    default =   "appinsights"
}

variable "storageAccountName" {
    type    =   string
    default =   "storage"
}

variable "storageAccountTier" {
    type    =   string
    default =   "Standard"
}

variable "storageAccountReplicationType" {
    type    =   string
    default =   "LRS"
}

variable "IS_GCP" {
    type    =   string
    default =   "Azure"
}

variable "PROMETHEUS_URL" {
    type    =   string
    default =   "http://prometheus23092021.westeurope.azurecontainer.io:9090/"
}

variable "RESTO_URL" {
    type    =   string
    default =   ""
}

variable "PROMETHEUS_LOGIN" {
    type    =   string
    default =   ""
}

variable "PROMETHEUS_PASSWORD" {
    type    =   string
    default =   ""
}