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
