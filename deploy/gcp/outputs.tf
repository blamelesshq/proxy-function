output "api_url" {
  value = "${google_api_gateway_gateway.gw.default_hostname}/proxy-function"
  description = "Use this URL for fetch a data from the Prometheus via API RUN function"
}

output "api_key" {
  value = google_apikeys_key.proxy-function-key.key_string
  description = "API key to access function"
  sensitive = true
}
