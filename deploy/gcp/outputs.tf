output "api_key" {
  value = "${google_cloudfunctions_function.function.https_trigger_url}"
  description = "Use this URL for fetch a data from the Prometheus"
}