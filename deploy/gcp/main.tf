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

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  # member = "serviceAccount:${google_service_account.run_account.email}"
  member = "allUsers"
}

resource "google_endpoints_service" "openapi_service" {
  service_name = replace(local.api_gateway_url, "https://", "")
  project        = "${var.project}"
  openapi_config = templatefile(
    "./openapi_spec.yml",
    {
      host = replace(local.api_gateway_url, "https://", "")
      function_url = google_cloudfunctions_function.function.https_trigger_url
    }
  )

  depends_on = ["google_cloud_run_service.default"]

  provisioner "local-exec" {
    command = "gcloud beta run services update ${google_cloud_run_service.default.name} --set-env-vars ENDPOINTS_SERVICE_NAME=${self.service_name} --platform=managed --region=${var.region} --project=${var.project} --quiet"
  }
}

resource "google_cloud_run_service" "default" {
  location = "${var.region}"
  name     = "api-gateway-v-${var.api_version_major}-${var.api_version_minor}"

  template {
    spec {
      # TODO(illia-korotia): with custom service_account_name we get error. I wait a response to my issue.
      # service_account_name = google_service_account.run_account.email
      containers {
        image = "gcr.io/endpoints-release/endpoints-runtime-serverless:2"
      }
    }
  }
}

locals {
  api_gateway_url = google_cloud_run_service.default.status[0].url
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

# resource "google_service_account" "run_account" {
#   account_id   = "osdu-gcp-sa"
#   display_name = "Account for GCP RUN services"
# }

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}
