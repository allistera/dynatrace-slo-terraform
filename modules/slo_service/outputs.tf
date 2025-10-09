output "latency" {
  description = "Latency SLO resource"
  value = {
    id   = dynatrace_slo.this["latency"].id
    name = dynatrace_slo.this["latency"].name
  }
}

output "availability" {
  description = "Availability SLO resource"
  value = {
    id   = dynatrace_slo.this["availability"].id
    name = dynatrace_slo.this["availability"].name
  }
}

output "traffic" {
  description = "Traffic SLO resource"
  value = {
    id   = dynatrace_slo.this["traffic"].id
    name = dynatrace_slo.this["traffic"].name
  }
}

output "errors" {
  description = "Error rate SLO resource"
  value = {
    id   = dynatrace_slo.this["errors"].id
    name = dynatrace_slo.this["errors"].name
  }
}

output "latency_metric_key" {
  description = "Metric key for the latency SLO"
  value       = "func:slo.${dynatrace_slo.this["latency"].metric_name}"
}

output "availability_metric_key" {
  description = "Metric key for the availability SLO"
  value       = "func:slo.${dynatrace_slo.this["availability"].metric_name}"
}

output "traffic_metric_key" {
  description = "Metric key for the traffic SLO"
  value       = "func:slo.${dynatrace_slo.this["traffic"].metric_name}"
}

output "error_rate_metric_key" {
  description = "Metric key for the error rate SLO"
  value       = "func:slo.${dynatrace_slo.this["errors"].metric_name}"
}
