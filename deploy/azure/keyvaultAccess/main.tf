provider "azurerm" {
  version = "=2.47.0"
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "keyvault" {
  key_vault_id = var.keyvault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.identity_id

  secret_permissions = [
    "Get",
    "List",
  ]
}