data "azurerm_client_config" "current" {}

resource "null_resource" "example1" {
  provisioner "local-exec" {
    command = "cd ../../../Splunk; sudo chmod +x ./ProxyFunctionRouteUpdater ; ./ProxyFunctionRouteUpdater ${var.key_vault_name} ${var.azure_func_name}"
  }
}