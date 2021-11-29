data "azurerm_client_config" "current" {}

resource "null_resource" "example1" {
  provisioner "local-exec" {
    command = "cd ../../../FuncCodeBuilder/ProxyFuncRouteUpdater; ./ProxyFunctionRouteUpdater FunctionApp ${var.code_directory} ${var.key_vault_name} ${var.azure_func_name}; ./ProxyFunctionRouteUpdater ApiManagement ${var.code_directory} ../../deploy/azure ${var.azure_func_name} ;cd ../../deploy/azure;  az apim api import -g ${var.resource_group_name} --service-name ${var.apimanagement_name} --api-id ${var.apimanagement_name} --subscription-required false --api-revision ${var.apimanagement_revision} --path / --specification-format OpenApiJson --specification-path api-spec.yml; az apim api release create --resource-group ${var.resource_group_name} --service-name ${var.apimanagement_name} --api-id ${var.apimanagement_name} --api-revision ${var.apimanagement_revision}"
  }
}