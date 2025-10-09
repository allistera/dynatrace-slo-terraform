locals {
  slo_resources = {
    for key, slo in dynatrace_slo.this :
    key => {
      id          = slo.id
      name        = slo.name
      metric_name = slo.metric_name
    }
  }

  slo_metric_keys = {
    for key, details in local.slo_resources :
    key => "func:slo.${details.metric_name}"
  }
}

output "latency" {
  description = "Latency SLO resource"
  value       = lookup(local.slo_resources, "latency", null)
}

output "availability" {
  description = "Availability SLO resource"
  value       = lookup(local.slo_resources, "availability", null)
}

output "traffic" {
  description = "Traffic SLO resource"
  value       = lookup(local.slo_resources, "traffic", null)
}

output "errors" {
  description = "Error rate SLO resource"
  value       = lookup(local.slo_resources, "errors", null)
}

output "latency_metric_key" {
  description = "Metric key for the latency SLO"
  value       = lookup(local.slo_metric_keys, "latency", null)
}

output "availability_metric_key" {
  description = "Metric key for the availability SLO"
  value       = lookup(local.slo_metric_keys, "availability", null)
}

output "traffic_metric_key" {
  description = "Metric key for the traffic SLO"
  value       = lookup(local.slo_metric_keys, "traffic", null)
}

output "error_rate_metric_key" {
  description = "Metric key for the error rate SLO"
  value       = lookup(local.slo_metric_keys, "errors", null)
}

output "slos" {
  description = "Map of all SLO resources keyed by SLO type"
  value       = local.slo_resources
}

output "metric_keys" {
  description = "Map of all SLO metric keys keyed by SLO type"
  value       = local.slo_metric_keys
}
