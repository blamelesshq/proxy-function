data "archive_file" "function" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/gcp/"
  output_path = "${path.module}/function_gcp.zip"
}

locals {
  api_config_id_prefix = ""
  api_id               = "proxy-function-gateway"
  gateway_id           = "proxy-function-gateway"
  display_name         = "Proxy Function Gateway"
  openapi_spec         = templatefile("./openapi_spec.yml", { function_url = google_cloudfunctions_function.function.https_trigger_url })
}

resource "google_storage_bucket" "bucket" {
  name     = var.proxy_bucket_name
  location = var.proxy_bucket_location
}

resource "google_storage_bucket_object" "archive" {
  name   = "function_gcp.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./function_gcp.zip"

  depends_on = [
    data.archive_file.function
  ]
}

resource "google_cloudfunctions_function" "function" {
  name        = var.proxy_function_name
  description = "blameless-proxy-function"
  runtime     = "go116"
  region      = var.region

  vpc_connector = var.vpc_connector

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "HandleQuery"

  environment_variables = {
    DATA_SOURCE_USERNAME = "${var.data_source_username}"
    DATA_SOURCE_URL      = "${var.data_source_url}"
    DATA_SOURCE_PASSWORD = "${var.data_source_password}"
    FUNCTION_TYPE        = "${var.data_source_type}"
  }
}

resource "google_service_account" "proxy_function_invoker" {
  account_id   = var.proxy_service_account
  display_name = "Account for GCP RUN services"
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.proxy_function_invoker.email}"
}

resource "google_api_gateway_api" "api_gw" {
  provider     = google-beta
  api_id       = local.api_id
  project      = var.project_id
  display_name = local.display_name
}

resource "google_api_gateway_api_config" "api_cfg" {
  provider             = google-beta
  api                  = google_api_gateway_api.api_gw.api_id
  api_config_id_prefix = local.api_config_id_prefix
  project              = var.project_id
  display_name         = local.display_name

  depends_on = [google_api_gateway_api.api_gw]

  openapi_documents {
    document {
      path     = "${path.module}/openapi_spec.yml"
      contents = base64encode(local.openapi_spec)
    }
  }
  gateway_config {
    backend_config {
      google_service_account = google_service_account.proxy_function_invoker.email
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "gw" {
  provider = google-beta
  region   = var.region
  project  = var.project_id


  api_config = google_api_gateway_api_config.api_cfg.id

  gateway_id   = local.gateway_id
  display_name = local.display_name

  depends_on = [google_api_gateway_api_config.api_cfg]
}

resource "google_project_service" "api_gateway" {
  project = var.project_id
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
  project = var.project_id
  service = "apikeys.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = false
}

resource "google_apikeys_key" "proxy_function_key" {
  name         = "proxy-function-key-${google_api_gateway_api_config.api_cfg.id}"
  display_name = "Proxy Function Key"
  project      = var.project_id

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
