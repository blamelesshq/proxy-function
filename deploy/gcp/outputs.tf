output "function_url" {
  value = "${google_cloudfunctions_function.function.https_trigger_url}"
  description = "Use this URL for fetch a data from the Prometheus via GCP function"
}

output "api_url" {
  value = "${google_cloud_run_service.default.status[0].url}/fetch"
  description = "Use this URL for fetch a data from the Prometheus via API RUN function"
}
