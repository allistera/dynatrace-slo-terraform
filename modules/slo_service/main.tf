terraform {
  required_version = ">= 1.0.0"

  required_providers {
    dynatrace = {
      source  = "dynatrace-oss/dynatrace"
      version = "~> 1.0"
    }
  }
}

locals {
  slo_definitions = {
    latency = {
      display_name     = "Latency"
      description      = "Measures the latency performance of ${var.service_name}"
      target           = var.latency_target
      warning          = var.latency_warning
      metric_expression = format(
        "(100)*(builtin:service.response.time:splitBy():percentile(%s))/(%s)",
        var.latency_percentile,
        var.latency_threshold_ms,
      )
      metric_name = "latency_slo"
    }
    availability = {
      display_name     = "Availability"
      description      = "Measures the availability of ${var.service_name} based on success rate"
      target           = var.availability_target
      warning          = var.availability_warning
      metric_expression = "(100)*((builtin:service.requestCount.total:splitBy():sum)-(builtin:service.errors.total.count:splitBy():sum))/(builtin:service.requestCount.total:splitBy():sum)"
      metric_name       = "availability_slo"
    }
    traffic = {
      display_name     = "Traffic"
      description      = "Monitors traffic throughput for ${var.service_name}"
      target           = var.traffic_target
      warning          = var.traffic_warning
      metric_expression = format(
        "(100)*(builtin:service.requestCount.total:splitBy():count:rate(1m))/(%s)",
        var.traffic_threshold_rpm,
      )
      metric_name = "traffic_slo"
    }
    errors = {
      display_name     = "Error Rate"
      description      = "Tracks the error rate for ${var.service_name}"
      target           = var.error_rate_target
      warning          = var.error_rate_warning
      metric_expression = "(100)-((100)*(builtin:service.errors.total.count:splitBy():sum)/(builtin:service.requestCount.total:splitBy():sum))"
      metric_name       = "error_rate_slo"
    }
  }
}

resource "dynatrace_slo" "this" {
  for_each = local.slo_definitions

  name        = "${var.service_name} - ${each.value.display_name}"
  disabled    = false
  description = each.value.description
  evaluation  = "AGGREGATE"
  target      = each.value.target
  warning     = each.value.warning
  timeframe   = var.timeframe

  metric_expression = each.value.metric_expression
  metric_name       = each.value.metric_name
}
