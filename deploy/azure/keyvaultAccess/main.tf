provider "azurerm" {
  version = ">=2.21.0"
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "keyvault" {
  key_vault_id = var.keyVaultId
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.identityId

  secret_permissions = [
    "Get",
    "List",
  ]
}