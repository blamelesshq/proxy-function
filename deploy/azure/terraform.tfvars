# General
resource_group_name                         = "rg-blameless-prometheus"
location                                    = "westeurope"

# KeyVault
keyvault_name                               = "kv-blameless-prometheus"
PROMETHEUS_URL                              = "http://prometheus23092021.westeurope.azurecontainer.io:9090/"
RESTO_URL                                   = ""
PROMETHEUS_LOGIN                            = ""
PROMETHEUS_PASSWORD                         = ""

#AzureFunction
sku_tier                                    = "Dynamic"
sku_size                                    = "Y1"
functionapp_name                            = "fa-blameless-prometheus"
appinsights_name                            = "ai-blameless-prometheus"
storage_account_name                        = "stblamelessprometheus"
storage_account_tier                        = "Standard"
storage_account_replication_type            = "LRS"
CLOUD_PLATFORM                              = "Azure"
azure_func_name                             = "blamelessprometheusfunc"

#ApiManagement
apimanagement_name                          = "amblamelessprometheus"
publisher_name                              = "Blameless"
admin_email                                 = "admin@blameless.com"
sku_name                                    = "Consumption_0"
apimanagement_display_name                  = "Blameless"