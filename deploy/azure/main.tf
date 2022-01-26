module "apiManagementSpecBuilder" {
  source = "./apiManagementSpecBuilder"
  azure_func_name = var.azure_func_name
  code_directory  = var.code_directory
}

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
  RouteConfig                       = "@Microsoft.KeyVault(SecretUri=${module.keyvault.vault_uri}secrets/RouteConfig)"
  resource_group_id                 = module.resourceGroup.resource_group_id
  resource_group_name               = module.resourceGroup.resource_group_name
}

module "functionDeploy" {
  source          = "./functionDeploy"
  azure_func_name = module.function.functionapp_name
  key_vault_name  = var.keyvault_name
  code_directory  = var.code_directory
}

module "keyvaultAccess" {
  source                            = "./keyvaultAccess"
  identity_id                       = module.function.identity_id
  keyvault_id                       = module.keyvault.kv_id
}

module "apiManagement" {
  source                            = "./apiManagement"
  location                          = var.location
  resource_group_name               = module.resourceGroup.resource_group_name#var.resource_group_name
  publisher_name                    = var.publisher_name
  admin_email                       = var.admin_email
  sku_name                          = var.sku_name
  azure_func_name                   = module.function.name#var.azure_func_name
  apimanagement_name                = var.apimanagement_name
}

module "apiManagementImport" {
  source              = "./apiManagementImport"
  resource_group_name = module.resourceGroup.resource_group_name
  apimanagement_name  = module.apiManagement.apimanagement_name
}

module "natGateway" {
  source                 = "./natGateway"
  resource_group_name    = module.resourceGroup.resource_group_name
  natGateway_name        = "nat-${var.functionapp_name}"
  vnet_name              = "vnet-${var.functionapp_name}"
  subnet_name            = "subnet-${var.functionapp_name}"
  public_ip_name         = "ip-${var.functionapp_name}"
  subnet_delegation_name = "snetdel-${var.functionapp_name}"
  app_service_id         = module.function.functionapp_id
  location               = var.location
}