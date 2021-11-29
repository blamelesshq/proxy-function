# General - Resource Group
resource_group_name                         = "rg-blameless-splunk-19111"
location                                    = "westus"
code_directory                              = "../../ProxyFunction"

# KeyVault
keyvault_name                               = "kv-blameless-splunk19111"
RouteConfig                                  = ""

#AzureFunction
sku_tier                                    = "Standard"
sku_size                                    = "S1"
functionapp_name                            = "fa-blameless-splunk19111"
appinsights_name                            = "ai-blameless-splunk19111"
storage_account_name                        = "stblamelesssplunk19111"
storage_account_tier                        = "Standard"
storage_account_replication_type            = "LRS"
CLOUD_PLATFORM                              = "Azure"
azure_func_name                             = "blamelesssplunk19111"

#ApiManagement
apimanagement_name                          = "amblamelesssplunk19111"
publisher_name                              = "Blameless"
admin_email                                 = "admin@blameless.com"
sku_name                                    = "Consumption_0"