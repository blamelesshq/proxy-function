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

variable "api_gateway_deploy_name" {
  type = string
  description = "Deployment name for API gateway"
}
