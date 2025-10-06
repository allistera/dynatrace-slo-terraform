terraform {
  required_version = ">= 1.0.0"

  required_providers {
    dynatrace = {
      source  = "dynatrace-oss/dynatrace"
      version = "~> 1.0"
    }
  }
}

provider "dynatrace" {
  dt_env_url   = var.dynatrace_environment_url
  dt_api_token = var.dynatrace_api_token
}

module "slo_service" {
  source = "./modules/slo_service"

  service_name           = var.service_name
  timeframe              = var.timeframe
  latency_target         = var.latency_target
  latency_warning        = var.latency_warning
  latency_threshold_ms   = var.latency_threshold_ms
  latency_percentile     = var.latency_percentile
  availability_target    = var.availability_target
  availability_warning   = var.availability_warning
  traffic_target         = var.traffic_target
  traffic_warning        = var.traffic_warning
  traffic_threshold_rpm  = var.traffic_threshold_rpm
  error_rate_target      = var.error_rate_target
  error_rate_warning     = var.error_rate_warning
}

resource "dynatrace_http_monitor" "todoservice_uptime" {
  name      = "${var.service_name} - Uptime Check"
  enabled   = true
  frequency = 5

  locations = var.synthetic_locations

  script {
    request {
      description = "Check if service is up"
      method      = "GET"
      url         = var.service_url

      validation {
        rule {
          type  = "httpStatusesList"
          value = "200-299"
        }
      }
    }
  }
}
