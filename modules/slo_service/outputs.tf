output "latency" {
  description = "Latency SLO resource"
  value = {
    id   = dynatrace_slo.latency.id
    name = dynatrace_slo.latency.name
  }
}

output "availability" {
  description = "Availability SLO resource"
  value = {
    id   = dynatrace_slo.availability.id
    name = dynatrace_slo.availability.name
  }
}

output "traffic" {
  description = "Traffic SLO resource"
  value = {
    id   = dynatrace_slo.traffic.id
    name = dynatrace_slo.traffic.name
  }
}

output "errors" {
  description = "Error rate SLO resource"
  value = {
    id   = dynatrace_slo.errors.id
    name = dynatrace_slo.errors.name
  }
}

output "latency_metric_key" {
  description = "Metric key for the latency SLO"
  value       = "func:slo.${dynatrace_slo.latency.metric_name}"
}

output "availability_metric_key" {
  description = "Metric key for the availability SLO"
  value       = "func:slo.${dynatrace_slo.availability.metric_name}"
}

output "traffic_metric_key" {
  description = "Metric key for the traffic SLO"
  value       = "func:slo.${dynatrace_slo.traffic.metric_name}"
}

output "error_rate_metric_key" {
  description = "Metric key for the error rate SLO"
  value       = "func:slo.${dynatrace_slo.errors.metric_name}"
}
