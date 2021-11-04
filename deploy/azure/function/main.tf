data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "funcdeploy" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
}

resource "azurerm_storage_container" "funcdeploy" {
  name                  = "contents"
  storage_account_name  = azurerm_storage_account.funcdeploy.name
  container_access_type = "private"
}

resource "azurerm_application_insights" "funcdeploy" {
  name                = var.appinsights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"

  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/1303
  tags = {
    "hidden-link:${var.resource_group_id}/providers/Microsoft.Web/sites/${var.azure_func_name}" = "Resource"
  }

}

resource "azurerm_app_service_plan" "funcdeploy" {
  name                = var.functionapp_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = var.sku_tier
    size = var.sku_size
  }
}

resource "azurerm_function_app" "funcdeploy" {
  name                       = var.azure_func_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.funcdeploy.id
  storage_account_name       = azurerm_storage_account.funcdeploy.name
  storage_account_access_key = azurerm_storage_account.funcdeploy.primary_access_key
  https_only                 = true
  version                    = "~3"
  os_type                    = "linux"
  # To see this - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app#vnet_route_all_enabled 
  app_settings = {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
      "WEBSITE_VNET_ROUTE_ALL"   = "1"
      "FUNCTIONS_WORKER_RUNTIME" = "custom"
      "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.funcdeploy.instrumentation_key}"
      "SPLUNK_URL" = "${var.SPLUNK_URL}"
      "SPLUNK_ACCESS_TOKEN" = "${var.SPLUNK_ACCESS_TOKEN}"
      # "CLOUD_PLATFORM" = "${var.CLOUD_PLATFORM}"
      # "PROMETHEUS_PASSWORD" = "${var.PROMETHEUS_PASSWORD}"
      # "PROMETHEUS_LOGIN" = "${var.PROMETHEUS_LOGIN}"
      # "RESTO_URL" = "${var.RESTO_URL}"
      # "PROMETHEUS_URL" = "${var.PROMETHEUS_URL}"
  }


  # Enable if you need Managed Identity
  identity {
    type = "SystemAssigned"
  }
}