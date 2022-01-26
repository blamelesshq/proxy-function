data "azurerm_client_config" "current" {}

resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "cd ../../FuncCodeBuilder/ProxyFuncRouteUpdater; ./ProxyFunctionRouteUpdater Azure ApiManagement ${var.code_directory} ../../deploy/azure ${var.azure_func_name}" 
  }
}