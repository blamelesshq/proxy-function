data "azurerm_client_config" "current" {}

resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "cd ../../FuncCodeBuilder/ProxyFuncRouteUpdater; ./ProxyFunctionRouteUpdater ApiManagement ../../Splunk ../../deploy/azure ${var.azure_func_name}" 
  }
}