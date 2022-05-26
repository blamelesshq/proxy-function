variable "project_id" {
  description = "Google Cloud project id for deploy"
  type        = string
}

variable "region" {
  description = "Google Cloud region for deploy"
  type        = string
}

variable "proxy_bucket_name" {
  default     = "proxy-function-source"
  description = "Bucket to create and host proxy function"
  type        = string
}

variable "proxy_bucket_location" {
  default     = "US"
  description = "Bucket to create and host proxy function"
  type        = string
}

variable "proxy_function_name" {
  default     = "proxy-function"
  description = "A user-defined name of the function. Function names must be unique globally"
  type        = string
}

variable "proxy_service_account" {
  default     = "proxy-function-invoker"
  description = "Service account name for proxy service"
  type        = string

}

variable "data_source_url" {
  description = "URL to data source"
  type        = string
}

variable "data_source_username" {
  description = "Username for data source"
  type        = string
}

variable "data_source_password" {
  description = "Password for data source"
  sensitive   = true
  type        = string
}

variable "data_source_type" {
  description = "Data source type. ('prometheus', 'splunk')"
  type        = string

  validation {
    condition     = contains(["prometheus", "splunk"], var.data_source_type)
    error_message = "Valid values for var: data_source_type are ('prometheus', 'splunk')."
  }
}

variable "vpc_acccess_connector" {
  default     = null
  description = "The VPC Network Connector that this cloud function can connect to. It should be set up as fully-qualified URI."
  nullable    = true
  type        = string
}
