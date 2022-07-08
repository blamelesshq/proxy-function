output "api_url" {
  value       = "${google_api_gateway_gateway.gw.default_hostname}/proxy-function"
  description = "Use this URL for fetch a data from the Prometheus via API RUN function"
}
