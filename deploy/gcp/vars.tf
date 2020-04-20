variable "prometheus_url" {
  type = string
  description = "URL to prometheus"
}

variable "prometheus_login" {
  type = string
  description = "Login for Prometheus"
}

variable "prometheus_password" {
  type = string
  description = "Password for Prometheus"
}

variable "project" {
  type = string
  description = "Porjcet ID/Name for deploy"
}

variable "region" {
  type = string
  description = "Region for deploy"
}

variable "api_version_minor" {
  type= string
  description = "API minor version"
}

variable "api_version_major" {
  type= string
  description = "API major version"
}
