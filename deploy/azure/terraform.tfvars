# General - Resource Group
resource_group_name                         = "rg-blameless-splunk-28"
location                                    = "westeurope"

# KeyVault
keyvault_name                               = "kv-blameless-splunk28"
#PROMETHEUS_URL                              = "http://prometheus18102021.westeurope.azurecontainer.io:9090/"
#RESTO_URL                                   = ""
#PROMETHEUS_LOGIN                            = ""
#PROMETHEUS_PASSWORD                         = ""
SPLUNK_URL                                   = "http://104.211.56.83:8089"
SPLUNK_ACCESS_TOKEN                          = "eyJraWQiOiJzcGx1bmsuc2VjcmV0IiwiYWxnIjoiSFM1MTIiLCJ2ZXIiOiJ2MiIsInR0eXAiOiJzdGF0aWMifQ.eyJpc3MiOiJzcGx1bmsgZnJvbSBzcGx1bmsiLCJzdWIiOiJzcGx1bmsiLCJhdWQiOiJWZW5kb3IgdG9vbHMiLCJpZHAiOiJTcGx1bmsiLCJqdGkiOiJkMzliNzI3MzI3ZTVjMmNhOThkMmNmOTIwMDEwYzRmNzBiYTVmNjg4ZmZkNzFjZjY5OTgxMjg0M2FmYWM2YWYzIiwiaWF0IjoxNjMyOTY1NjU1LCJleHAiOjE2NTAyNDU2NTUsIm5iciI6MTYzMjk2NTY1NX0.2Z0V_NlqzbI0F33k3twyC_w9yxMmu0gh-zEaXs_qUddfqdMU5bFkmHYms2zLPAjeovNVINiBtmBkejF4zivXoQ"

#AzureFunction
sku_tier                                    = "Standard"
sku_size                                    = "S1"
functionapp_name                            = "fa-blameless-splunk28"
appinsights_name                            = "ai-blameless-splunk28"
storage_account_name                        = "stblamelesssplunk28"
storage_account_tier                        = "Standard"
storage_account_replication_type            = "LRS"
CLOUD_PLATFORM                              = "Azure"
azure_func_name                             = "blamelesssplunk28"

#ApiManagement
apimanagement_name                          = "amblamelesssplunk28"
publisher_name                              = "Blameless"
admin_email                                 = "admin@blameless.com"
sku_name                                    = "Consumption_0"
apimanagement_display_name                  = "Blameless"