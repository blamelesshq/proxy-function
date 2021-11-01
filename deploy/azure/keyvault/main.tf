data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                        = var.keyvault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  #soft_delete_enabled         = false
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
      "list",
      "set",
      "delete"
    ]

    storage_permissions = [
      "get",
    ]
  }

  # network_acls {
  #   default_action = "Deny" # "Allow" 
  #   bypass         = "AzureServices" # "None"
  #   ip_rules = ["50.50.50.50/24"]
  # }
}

resource "azurerm_key_vault_secret" "SPLUNK_URL" {
  name         = "SPLUNK-URL"
  value        = var.SPLUNK_URL
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "SPLUNK_ACCESS_TOKEN" {
  name         = "SPLUNK-ACCESS-TOKEN"
  value        = var.SPLUNK_ACCESS_TOKEN
  key_vault_id = azurerm_key_vault.keyvault.id
}

# resource "azurerm_key_vault_secret" "PROMETHEUS_URL" {
#   name         = "PROMETHEUS-URL"
#   value        = var.PROMETHEUS_URL
#   key_vault_id = azurerm_key_vault.keyvault.id
# }

# resource "azurerm_key_vault_secret" "RESTO_URL" {
#   name         = "RESTO-URL"
#   value        = var.RESTO_URL
#   key_vault_id = azurerm_key_vault.keyvault.id
# }

# resource "azurerm_key_vault_secret" "PROMETHEUS_LOGIN" {
#   name         = "PROMETHEUS-LOGIN"
#   value        = var.PROMETHEUS_LOGIN
#   key_vault_id = azurerm_key_vault.keyvault.id
# }

# resource "azurerm_key_vault_secret" "PROMETHEUS_PASSWORD" {
#   name         = "PROMETHEUS-PASSWORD"
#   value        = var.PROMETHEUS_PASSWORD
#   key_vault_id = azurerm_key_vault.keyvault.id
# }

# resource "azurerm_key_vault_access_policy" "policy" {
#   key_vault_id = azurerm_key_vault.keyvault.id
#
#   tenant_id = data.azurerm_client_config.current.tenant_id
#   object_id = "11111111-1111-1111-1111-111111111111" # SPN ID
#
#   key_permissions = [
#     "get",
#   ]
#
#   secret_permissions = [
#     "get",
#   ]
# }