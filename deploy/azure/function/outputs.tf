output "identity_id" {
  value = azurerm_function_app.funcdeploy.identity.0.principal_id
}

output "hostname" {
  value = azurerm_function_app.funcdeploy.default_hostname
}

output "name" {
  value = azurerm_function_app.funcdeploy.name
}

output "functionapp_id" {
  value = azurerm_function_app.funcdeploy.id
}
