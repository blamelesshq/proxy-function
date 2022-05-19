terraform {
  backend "gcs" {
    bucket  = "cfd-terraform"
    prefix  = ""
  }
}

provider "google" {
  project = "${var.project}"
  region = "${var.region}"
  credentials = var.service_account_credentials
}

locals {
  api_config_id_prefix     = ""
  api_id                   = "proxy-function-gateway"
  gateway_id               = "proxy-function-gateway"
  display_name             = "Proxy Function Gateway"
  openapi_spec             = templatefile("./openapi_spec.yml", { function_url = google_cloudfunctions_function.function.https_trigger_url })
}

resource "google_storage_bucket" "bucket" {
  name     = "proxy-function-source"
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
  region      = "${var.region}"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "HandleQuery"

  environment_variables = {
    DATA_SOURCE_USERNAME="${var.data_source_username}"
    DATA_SOURCE_URL="${var.data_source_url}"
    DATA_SOURCE_PASSWORD="${var.data_source_password}"
    FUNCTION_TYPE="${var.data_source_type}"
  }
}

resource "google_service_account" "proxy-function-invoker" {
  account_id   = "proxy-function-invoker"
  display_name = "Account for GCP RUN services"
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.proxy-function-invoker.email}"
}

resource "google_api_gateway_api" "api_gw" {
  provider     = google-beta
  api_id       = local.api_id
  project      = var.project
  display_name = local.display_name
}

resource "google_api_gateway_api_config" "api_cfg" {
  provider             = google-beta
  api                  = google_api_gateway_api.api_gw.api_id
  api_config_id_prefix = local.api_config_id_prefix
  project              = var.project
  display_name         = local.display_name

  depends_on = [ google_api_gateway_api.api_gw ]

  openapi_documents {
    document {
      path     = "./openapi_spec.yml"
      contents = base64encode(local.openapi_spec)
    }
  }
  gateway_config {
    backend_config {
      google_service_account = google_service_account.proxy-function-invoker.email
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "gw" {
  provider = google-beta
  region   = var.region
  project  = var.project


  api_config   = google_api_gateway_api_config.api_cfg.id

  gateway_id   = local.gateway_id
  display_name = local.display_name

  depends_on   = [ google_api_gateway_api_config.api_cfg ]
}

resource "google_project_service" "api_gateway" {
  project = var.project
  service = google_api_gateway_api.api_gw.managed_service

  depends_on = [
    google_api_gateway_api.api_gw,
    google_api_gateway_gateway.gw
  ]

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = false
}

resource "google_project_service" "api_keys" {
  project = var.project
  service = "apikeys.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = false
}

resource "google_apikeys_key" "proxy-function-key" {
  name         = "proxy-function-key-${google_api_gateway_api_config.api_cfg.id}"
  display_name = "Proxy Function Key"
  project      = var.project

  depends_on = [
    google_project_service.api_keys,
    google_api_gateway_api_config.api_cfg,
    google_api_gateway_api.api_gw
  ]

  restrictions {
    api_targets {
      service = google_api_gateway_api.api_gw.managed_service
    }
  }
}
