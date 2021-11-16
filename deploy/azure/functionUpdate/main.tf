data "azurerm_client_config" "current" {}

resource "null_resource" "example1" {
  provisioner "local-exec" {
    command = "cd ../../../FuncCodeBuilder/ProxyFuncRouteUpdater; ./ProxyFunctionRouteUpdater ${var.key_vault_name} ${var.azure_func_name}"
  }
}