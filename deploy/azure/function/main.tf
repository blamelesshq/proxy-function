# https://github.com/terraform-providers/terraform-provider-azurerm/issues/7960
provider "azurerm" {
  version = ">=2.21.0"
  features {}
}

resource "azurerm_resource_group" "funcdeploy" {
  name     = "rg-${var.prefix}-function"
  location = var.location
}

resource "azurerm_storage_account" "funcdeploy" {
  name                     = "${var.prefix}${var.storageAccountName}"
  resource_group_name      = azurerm_resource_group.funcdeploy.name
  location                 = azurerm_resource_group.funcdeploy.location
  account_tier             = "${var.storageAccountTier}"
  account_replication_type = "${var.storageAccountReplicationType}"
}

resource "azurerm_storage_container" "funcdeploy" {
  name                  = "contents"
  storage_account_name  = azurerm_storage_account.funcdeploy.name
  container_access_type = "private"
}

resource "azurerm_application_insights" "funcdeploy" {
  name                = "${var.prefix}-${var.appInsightsName}"
  location            = azurerm_resource_group.funcdeploy.location
  resource_group_name = azurerm_resource_group.funcdeploy.name
  application_type    = "web"

  # https://github.com/terraform-providers/terraform-provider-azurerm/issues/1303
  tags = {
    "hidden-link:${azurerm_resource_group.funcdeploy.id}/providers/Microsoft.Web/sites/${var.prefix}func" = "Resource"
  }

}

resource "azurerm_app_service_plan" "funcdeploy" {
  name                = "${var.prefix}-${var.functionAppName}"
  location            = azurerm_resource_group.funcdeploy.location
  resource_group_name = azurerm_resource_group.funcdeploy.name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "${var.skuTier}"
    size = "${var.skuSize}"
  }
}

resource "azurerm_function_app" "funcdeploy" {
  name                       = "${var.prefix}func"
  location                   = azurerm_resource_group.funcdeploy.location
  resource_group_name        = azurerm_resource_group.funcdeploy.name
  app_service_plan_id        = azurerm_app_service_plan.funcdeploy.id
  storage_account_name       = azurerm_storage_account.funcdeploy.name
  storage_account_access_key = azurerm_storage_account.funcdeploy.primary_access_key
  https_only                 = true
  version                    = "~3"
  os_type                    = "linux"
  app_settings = {
      "WEBSITE_RUN_FROM_PACKAGE" = "1"
      "FUNCTIONS_WORKER_RUNTIME" = "custom"
      "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.funcdeploy.instrumentation_key}"
      "IS_GCP" = "${var.IS_GCP}"
      "PROMETHEUS_PASSWORD" = "${var.PROMETHEUS_PASSWORD}"
      "PROMETHEUS_LOGIN" = "${var.PROMETHEUS_LOGIN}"
      "RESTO_URL" = "${var.RESTO_URL}"
      "PROMETHEUS_URL" = "${var.PROMETHEUS_URL}"
  }


  # Enable if you need Managed Identity
  identity {
    type = "SystemAssigned"
  }
}