output "latency_slo_id" {
  description = "ID of the latency SLO"
  value       = dynatrace_slo.todoservice_latency.id
}

output "availability_slo_id" {
  description = "ID of the availability SLO"
  value       = dynatrace_slo.todoservice_availability.id
}

output "traffic_slo_id" {
  description = "ID of the traffic SLO"
  value       = dynatrace_slo.todoservice_traffic.id
}

output "error_rate_slo_id" {
  description = "ID of the error rate SLO"
  value       = dynatrace_slo.todoservice_errors.id
}

output "slo_summary" {
  description = "Summary of all created SLOs"
  value = {
    service_name = var.service_name
    slos = {
      latency = {
        id     = dynatrace_slo.todoservice_latency.id
        name   = dynatrace_slo.todoservice_latency.name
        target = var.latency_target
      }
      availability = {
        id     = dynatrace_slo.todoservice_availability.id
        name   = dynatrace_slo.todoservice_availability.name
        target = var.availability_target
      }
      traffic = {
        id     = dynatrace_slo.todoservice_traffic.id
        name   = dynatrace_slo.todoservice_traffic.name
        target = var.traffic_target
      }
      errors = {
        id     = dynatrace_slo.todoservice_errors.id
        name   = dynatrace_slo.todoservice_errors.name
        target = var.error_rate_target
      }
    }
  }
}
