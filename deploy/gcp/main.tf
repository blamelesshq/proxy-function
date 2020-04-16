provider "google" {
  project     = "${var.project}"
  region = "${var.region}"
}


resource "google_storage_bucket" "bucket" {
  name = "source-code-prometheus-fetch"
}

resource "google_storage_bucket_object" "archive" {
  name   = "function_gcp.zip"
  bucket = google_storage_bucket.bucket.name
  source = "../../function_gcp.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "fetch-prometheus-data"
  description = "My function"
  runtime     = "go111"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "HandleRequestGCP"

  environment_variables = {
    PROMETHEUS_LOGIN="${var.prometheus_login}"
    PROMETHEUS_URL="${var.prometheus_url}"
    PROMETHEUS_PASSWORD="${var.prometheus_password}"
    IS_GCP="GCP"
  }
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
