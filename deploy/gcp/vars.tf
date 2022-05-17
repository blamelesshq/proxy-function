variable "data_source_url" {
  type = string
  description = "URL to data source"
} 

variable "data_source_username" {
  type = string
  description = "Username for data source"
}

variable "data_source_password" {
  type = string
  description = "Password for data source"
}

variable "project" {
  type = string
  description = "Google Cloud project id for deploy"
}

variable "region" {
  type = string
  description = "Google Cloud region for deploy"
}

variable "data_source_type" {
  type= string
  description = "Data source type. ('prometheus', 'splunk')"
}

variable "access_token" {
  type= string
  description = "Token to access the proxy function"
}

variable "api_version_minor" {
  type= string
  description = "API minor version"
}

variable "api_version_major" {
  type= string
  description = "API major version"
}