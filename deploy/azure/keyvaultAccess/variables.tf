variable "identity_id" {
  type        = string
  description = "Azure Function Service Principal object identifier"
  sensitive   = true
}

variable "keyvault_id" {
  type        = string
  description = "Azure Key Vault Identifier"
  sensitive   = true
}
