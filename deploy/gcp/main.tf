terraform {
  backend "gcs" {
    bucket  = "cfd-terraform"
    prefix  = ""
  }
}

provider "google" {
  project = "${var.project}"
  region = "${var.region}"
}

locals {
  api_gateway_url = google_cloud_run_service.default.status[0].url
}

resource "google_storage_bucket" "bucket" {
  name = "proxy-function-source"
  location = "US"
}

resource "google_storage_bucket_object" "archive" {
  name   = "function_gcp.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./function_gcp.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "proxy-function"
  description = "blameless-proxy-function"
  runtime     = "go116"
  region = "${var.region}"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "HandleQuery"

  environment_variables = {
    DATA_SOURCE_USERNAME="${var.data_source_username}"
    DATA_SOURCE_URL="${var.data_source_url}"
    DATA_SOURCE_PASSWORD="${var.data_source_password}"
    FUNCTION_ACCESS_TOKEN="${var.access_token}"
    FUNCTION_TYPE="${var.data_source_type}"
  }
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
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

  # depends_on = [google_cloud_run_service.default]

  # provisioner "local-exec" {
  #   command = "gcloud beta run services update ${google_cloud_run_service.default.name} --set-env-vars ENDPOINTS_SERVICE_NAME=${self.service_name} --platform=managed --region=${var.region} --project=${var.project}"
  # }
}

# resource "google_project_service" "api-project-service" {
#   service = google_endpoints_service.openapi_service.service_name
#   project = var.project_id
#   depends_on = [google_endpoints_service.openapi_service]
# }

resource "google_cloud_run_service" "default" {
  location = "${var.region}"
  name     = "api-gateway-v-${var.api_version_major}-${var.api_version_minor}"
  autogenerate_revision_name=true

  # depends_on = [google_endpoints_service.openapi_service]

  template {
    spec {
      # service_account_name = google_service_account.run_account.email
      containers {
        image = "gcr.io/endpoints-release/endpoints-runtime-serverless:2"
        env {
          name = "ENDPOINTS_SERVICE_NAME"
          value = "${google_endpoints_service.openapi_service.service_name}"
        }        
      }
    }
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

# resource "google_project_iam_member" "editor" {
#   project = var.project
#   role    = "roles/editor"
#   member  = "serviceAccount:${google_service_account.run_account.email}"
# }

# resource "google_service_account" "run_account" {
#   account_id   = "run-account"
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
