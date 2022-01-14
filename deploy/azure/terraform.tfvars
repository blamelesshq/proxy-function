# General - Resource Group
resource_group_name                         = "rg-blameless-splunk-0912"
location                                    = "westeurope"
code_directory                              = "../../ProxyFunction"

# KeyVault
keyvault_name                               = "kv-blameless-splunk0912"
RouteConfig                                  = ""

#AzureFunction
sku_tier                                    = "Standard"
sku_size                                    = "S1"
functionapp_name                            = "fa-blameless-splunk0912"
appinsights_name                            = "ai-blameless-splunk0912"
storage_account_name                        = "stblamelesssplunk0912"
storage_account_tier                        = "Standard"
storage_account_replication_type            = "LRS"
CLOUD_PLATFORM                              = "Azure"
azure_func_name                             = "blamelesssplunk0912"

#ApiManagement
apimanagement_name                          = "amblamelesssplunk0912"
publisher_name                              = "Blameless"
admin_email                                 = "admin@blameless.com"
sku_name                                    = "Consumption_0"