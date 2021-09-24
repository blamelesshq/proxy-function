module "keyvault" {
  source                            = "./keyvault"
  resource_group_name               = var.resource_group_name
  location                          = var.keyvault_location
  keyvault_name                     = var.keyvault_name
  secret_name                       = var.secret_name
  secret_value                      = var.secret_value
}


module "function" {
  source                            = "./function"
  location                          = var.location
  prefix                            = var.prefix
  skuTier                           = var.skuTier
  skuSize                           = var.skuSize
  functionAppName                   = var.functionAppName
  appInsightsName                   = var.appInsightsName
  storageAccountName                = var.storageAccountName
  storageAccountTier                = var.storageAccountTier
  storageAccountReplicationType     = var.storageAccountReplicationType
  IS_GCP                            = var.IS_GCP
  PROMETHEUS_URL                    = var.PROMETHEUS_URL
  RESTO_URL                         = var.RESTO_URL
  PROMETHEUS_LOGIN                  = var.PROMETHEUS_LOGIN
  PROMETHEUS_PASSWORD               = var.PROMETHEUS_PASSWORD
  TestKeyVault                      = "@Microsoft.KeyVault(SecretUri=${module.keyvault.vault_uri}secrets/${var.secret_name})"
}