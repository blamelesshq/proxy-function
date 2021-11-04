data "azurerm_client_config" "current" {}

resource "null_resource" "example1" {
   provisioner "local-exec" {
    command = "sleep 15; cd ../../Splunk; func azure functionapp publish ${var.azure_func_name}"
  }
}