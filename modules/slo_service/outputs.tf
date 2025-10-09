locals {
  slo_outputs = {
    for key, resource in dynatrace_slo.this :
    key => {
      id         = resource.id
      name       = resource.name
      metric_key = "func:slo.${resource.metric_name}"
    }
  }
}

output "latency" {
  description = "Latency SLO resource"
  value       = lookup(local.slo_outputs, "latency", null)
}

output "availability" {
  description = "Availability SLO resource"
  value       = lookup(local.slo_outputs, "availability", null)
}

output "traffic" {
  description = "Traffic SLO resource"
  value       = lookup(local.slo_outputs, "traffic", null)
}

output "errors" {
  description = "Error rate SLO resource"
  value       = lookup(local.slo_outputs, "errors", null)
}

output "latency_metric_key" {
  description = "Metric key for the latency SLO"
  value       = try(local.slo_outputs["latency"].metric_key, null)
}

output "availability_metric_key" {
  description = "Metric key for the availability SLO"
  value       = try(local.slo_outputs["availability"].metric_key, null)
}

output "traffic_metric_key" {
  description = "Metric key for the traffic SLO"
  value       = try(local.slo_outputs["traffic"].metric_key, null)
}

output "error_rate_metric_key" {
  description = "Metric key for the error rate SLO"
  value       = try(local.slo_outputs["errors"].metric_key, null)
}
