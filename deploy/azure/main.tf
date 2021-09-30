module "resourceGroup" {
  source = "./resourceGroup"
  resource_group_name               = var.resource_group_name
  location                          = var.location
}

module "keyvault" {
  source                            = "./keyvault"
  resource_group_name               = module.resourceGroup.resource_group_name
  location                          = var.location
  keyvault_name                     = var.keyvault_name
  PROMETHEUS_URL                    = var.PROMETHEUS_URL
  RESTO_URL                         = var.RESTO_URL
  PROMETHEUS_LOGIN                  = var.PROMETHEUS_LOGIN
  PROMETHEUS_PASSWORD               = var.PROMETHEUS_PASSWORD
}

module "function" {
  source                            = "./function"
  location                          = var.location
  sku_tier                          = var.sku_tier
  sku_size                          = var.sku_size
  functionapp_name                  = var.functionapp_name
  appinsights_name                  = var.appinsights_name
  storage_account_name              = var.storage_account_name
  storage_account_tier              = var.storage_account_tier
  storage_account_replication_type  = var.storage_account_replication_type
  azure_func_name                   = var.azure_func_name
  CLOUD_PLATFORM                    = var.CLOUD_PLATFORM
  PROMETHEUS_URL                    = "@Microsoft.KeyVault(SecretUri=${module.keyvault.vault_uri}secrets/PROMETHEUS-URL)"
  RESTO_URL                         = "@Microsoft.KeyVault(SecretUri=${module.keyvault.vault_uri}secrets/RESTO-URL)"
  PROMETHEUS_LOGIN                  = "@Microsoft.KeyVault(SecretUri=${module.keyvault.vault_uri}secrets/PROMETHEUS-LOGIN)"
  PROMETHEUS_PASSWORD               = "@Microsoft.KeyVault(SecretUri=${module.keyvault.vault_uri}secrets/PROMETHEUS-PASSWORD)"
  resource_group_id                 = module.resourceGroup.resource_group_id
  resource_group_name               = module.resourceGroup.resource_group_name
}

module "keyvaultAccess" {
  source                            = "./keyvaultAccess"
  identity_id                       = module.function.identity_id
  keyvault_id                       = module.keyvault.kv_id
}

# module "apiManagement" {
#   source                            = "./apiManagement"
#   resourceGroupName                 = var.resource_group_name#module.function.resourceGroup
#   azureFunctionHostname             = "310920211func.azurewebsites.net"#module.function.hostname
#   azureFunctionName                 = "310920211func"#module.function.name
#   apiManagementName                 = var.apiManagementName
# }