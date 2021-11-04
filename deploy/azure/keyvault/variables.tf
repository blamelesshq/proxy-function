variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
}

variable "location" {
  type        = string
  description = "RG location in Azure"
}

variable "keyvault_name" {
  type        = string
  description = "Key Vault name in Azure"
}

# variable "SPLUNK_URL" {
#   type        = string
#   description = "SPLUNK_URL"
# }

# variable "SPLUNK_ACCESS_TOKEN" {
#   type        = string
#   description = "SPLUNK_ACCESS_TOKEN"
# }

variable "RouteConfig" {
  type        = string
  description = "RouteConfig"
}


# variable "PROMETHEUS_URL" {
#   type        = string
#   description = "PROMETHEUS_URL"
# }

# variable "RESTO_URL" {
#   type        = string
#   description = "RESTO_URL"
# }

# variable "PROMETHEUS_LOGIN" {
#   type        = string
#   description = "PROMETHEUS_LOGIN"
# }

# variable "PROMETHEUS_PASSWORD" {
#   type        = string
#   description = "PROMETHEUS_PASSWORD"
# }