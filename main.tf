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

locals {
  guardian_name        = coalesce(var.guardian_name, "${var.service_name} Guardian")
  guardian_description = coalesce(var.guardian_description, "Site Reliability Guardian for ${var.service_name}")
}

module "slo_service" {
  source = "./modules/slo_service"

  service_name          = var.service_name
  timeframe             = var.timeframe
  latency_target        = var.latency_target
  latency_warning       = var.latency_warning
  latency_threshold_ms  = var.latency_threshold_ms
  latency_percentile    = var.latency_percentile
  availability_target   = var.availability_target
  availability_warning  = var.availability_warning
  traffic_target        = var.traffic_target
  traffic_warning       = var.traffic_warning
  traffic_threshold_rpm = var.traffic_threshold_rpm
  error_rate_target     = var.error_rate_target
  error_rate_warning    = var.error_rate_warning
}

locals {
  guardian_objectives = {
    latency = {
      name          = "Latency SLO"
      reference_slo = module.slo_service.latency_metric_key
      target        = var.latency_target
      warning       = var.latency_warning
    }
    availability = {
      name          = "Availability SLO"
      reference_slo = module.slo_service.availability_metric_key
      target        = var.availability_target
      warning       = var.availability_warning
    }
    traffic = {
      name          = "Traffic SLO"
      reference_slo = module.slo_service.traffic_metric_key
      target        = var.traffic_target
      warning       = var.traffic_warning
    }
    errors = {
      name          = "Error Rate SLO"
      reference_slo = module.slo_service.error_rate_metric_key
      target        = var.error_rate_target
      warning       = var.error_rate_warning
    }
  }
}

resource "dynatrace_site_reliability_guardian" "service" {
  count = var.enable_guardian ? 1 : 0

  name        = local.guardian_name
  description = local.guardian_description
  event_kind  = var.guardian_event_kind
  tags        = toset(var.guardian_tags)

  objectives {
    dynamic "objective" {
      for_each = local.guardian_objectives

      content {
        name                = objective.value.name
        objective_type      = "REFERENCE_SLO"
        reference_slo       = objective.value.reference_slo
        comparison_operator = "GREATER_THAN_OR_EQUAL"
        target              = objective.value.target
        warning             = objective.value.warning
      }
    }
  }
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
