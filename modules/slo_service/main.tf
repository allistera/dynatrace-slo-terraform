terraform {
  required_version = ">= 1.0"

  required_providers {
    dynatrace = {
      source  = "dynatrace-oss/dynatrace"
      version = "~> 1.0"
    }
  }
}

resource "dynatrace_slo" "latency" {
  name        = "${var.service_name} - Latency"
  disabled    = false
  description = "Measures the latency performance of ${var.service_name}"
  evaluation  = "AGGREGATE"
  target      = var.latency_target
  warning     = var.latency_warning
  timeframe   = var.timeframe

  metric_expression = "(100)*(builtin:service.response.time:splitBy():percentile(${var.latency_percentile}))/(${var.latency_threshold_ms})"
  metric_name       = "latency_slo"
}

resource "dynatrace_slo" "availability" {
  name        = "${var.service_name} - Availability"
  disabled    = false
  description = "Measures the availability of ${var.service_name} based on success rate"
  evaluation  = "AGGREGATE"
  target      = var.availability_target
  warning     = var.availability_warning
  timeframe   = var.timeframe

  metric_expression = "(100)*((builtin:service.requestCount.total:splitBy():sum)-(builtin:service.errors.total.count:splitBy():sum))/(builtin:service.requestCount.total:splitBy():sum)"
  metric_name       = "availability_slo"
}

resource "dynatrace_slo" "traffic" {
  name        = "${var.service_name} - Traffic"
  disabled    = false
  description = "Monitors traffic throughput for ${var.service_name}"
  evaluation  = "AGGREGATE"
  target      = var.traffic_target
  warning     = var.traffic_warning
  timeframe   = var.timeframe

  metric_expression = "(100)*(builtin:service.requestCount.total:splitBy():count:rate(1m))/(${var.traffic_threshold_rpm})"
  metric_name       = "traffic_slo"
}

resource "dynatrace_slo" "errors" {
  name        = "${var.service_name} - Error Rate"
  disabled    = false
  description = "Tracks the error rate for ${var.service_name}"
  evaluation  = "AGGREGATE"
  target      = var.error_rate_target
  warning     = var.error_rate_warning
  timeframe   = var.timeframe

  metric_expression = "(100)-((100)*(builtin:service.errors.total.count:splitBy():sum)/(builtin:service.requestCount.total:splitBy():sum))"
  metric_name       = "error_rate_slo"
}
