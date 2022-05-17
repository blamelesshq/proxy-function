output "api_url" {
  value = "${google_cloud_run_service.default.status[0].url}/proxy-function"
  description = "Use this URL for fetch a data from the Prometheus via API RUN function"
}
