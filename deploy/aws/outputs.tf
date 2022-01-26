output "deploy_api_geteway_url" {
  value = "${aws_api_gateway_deployment.deploy_api_gateway.invoke_url}/${var.api_gateway_deploy_name}"
  description = "Use this URL for fetch a data from the Prometheus"
}

output "api_key" {
  value = "${aws_api_gateway_api_key.aws_api_key_for_lambda_api.value}"
  description = "Use this token in each a request to the URL Prometheus"
  sensitive = true
}
