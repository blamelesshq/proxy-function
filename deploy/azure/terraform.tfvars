# General
resource_group_name                         = "rg-blameless-prometheus-3"
location                                    = "westeurope"

# KeyVault
keyvault_name                               = "kv-blameless-prometheuz"
PROMETHEUS_URL                              = "http://prometheus18102021.westeurope.azurecontainer.io:9090/"
RESTO_URL                                   = ""
PROMETHEUS_LOGIN                            = ""
PROMETHEUS_PASSWORD                         = ""

#AzureFunction
sku_tier                                    = "Standard"
sku_size                                    = "S1"
functionapp_name                            = "fa-blameless-prometheusss"
appinsights_name                            = "ai-blameless-prometheusss"
storage_account_name                        = "stblamelessprometheusss"
storage_account_tier                        = "Standard"
storage_account_replication_type            = "LRS"
CLOUD_PLATFORM                              = "Azure"
azure_func_name                             = "blamelessprometheusfuncss"

#ApiManagement
apimanagement_name                          = "amblamelessprometheusss"
publisher_name                              = "Blameless"
admin_email                                 = "admin@blameless.com"
sku_name                                    = "Consumption_0"
apimanagement_display_name                  = "Blameless"