provider "azurerm" {
    // Credentials should be set, az login is the easiest
    // other options are described here: https://www.terraform.io/docs/providers/azurerm/index.html
    version = "=2.47.0"
    features {}
}

resource "azurerm_api_management" "example" {
  name                = var.apimanagement_name
  resource_group_name = var.resource_group_name
  location            = var.location
  publisher_name      = var.publisher_name
  publisher_email     = var.admin_email
  sku_name            = var.sku_name
}

# Our general API definition, here we could include a nice swagger file or something
resource "azurerm_api_management_api" "example" {
  name                = var.apimanagement_name
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.example.name
  revision            = "2"
  display_name        = var.apimanagement_display_name
  path                = ""
  protocols           = ["https"]

  import {
    content_format = "openapi"
    content_value  = file("api-spec.yml")
  }
}

# We use a policy on our API to set the backend, which has the configuration for the authentication code
resource "azurerm_api_management_api_policy" "example" {
  api_name            = azurerm_api_management_api.example.name
  api_management_name = azurerm_api_management_api.example.api_management_name
  resource_group_name = var.resource_group_name

  # Put any policy block here, has to beh XML :(
  # More options: https://docs.microsoft.com/en-us/azure/api-management/api-management-policies
  xml_content = <<XML
    <policies>
        <inbound>
            <base />
            <set-backend-service base-url="https://${var.azure_func_name}.azurewebsites.net/api/" />
        </inbound>
    </policies>
  XML
}
