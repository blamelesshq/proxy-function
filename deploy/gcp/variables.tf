variable "project_id" {
  type        = string
  description = "Google Cloud project id for deploy"
}

variable "region" {
  type        = string
  description = "Google Cloud region for deploy"
}

variable "proxy_bucket_name" {
  type        = string
  default     = "proxy-function-source"
  description = "Bucket to create and host proxy function"
}

variable "proxy_bucket_location" {
  type        = string
  default     = "US"
  description = "Bucket to create and host proxy function"
}

variable "proxy_function_name" {
  type        = string
  default     = "proxy-function"
  description = "A user-defined name of the function. Function names must be unique globally"
}

variable "proxy_service_account" {
  type        = string
  default     = "proxy-function-invoker"
  description = "Service account name for proxy service"
}

variable "data_source_url" {
  type        = string
  description = "URL to data source"
}

variable "data_source_username" {
  type        = string
  description = "Username for data source"
}

variable "data_source_password" {
  type        = string
  sensitive   = true
  description = "Password for data source"
}

variable "data_source_type" {
  type        = string
  description = "Data source type. ('prometheus', 'splunk')"

  validation {
    condition     = contains(["prometheus", "splunk"], var.data_source_type)
    error_message = "Valid values for var: data_source_type are ('prometheus', 'splunk')."
  }
}