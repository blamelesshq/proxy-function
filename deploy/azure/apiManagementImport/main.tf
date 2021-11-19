data "azurerm_client_config" "current" {}

resource "null_resource" "example1" {
  provisioner "local-exec" {
    command = "sleep 15; az apim api import -g ${var.resource_group_name} --service-name ${var.apimanagement_name} --api-id ${var.apimanagement_name} --subscription-required false --path / --specification-format OpenApiJson --specification-path api-spec.yml" 
  }
}