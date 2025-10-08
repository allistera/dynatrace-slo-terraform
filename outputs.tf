output "latency_slo_id" {
  description = "ID of the latency SLO"
  value       = module.slo_service.latency.id
}

output "availability_slo_id" {
  description = "ID of the availability SLO"
  value       = module.slo_service.availability.id
}

output "traffic_slo_id" {
  description = "ID of the traffic SLO"
  value       = module.slo_service.traffic.id
}

output "error_rate_slo_id" {
  description = "ID of the error rate SLO"
  value       = module.slo_service.errors.id
}

output "slo_summary" {
  description = "Summary of all created SLOs"
  value = {
    service_name = var.service_name
    slos = {
      latency = {
        id     = module.slo_service.latency.id
        name   = module.slo_service.latency.name
        target = var.latency_target
      }
      availability = {
        id     = module.slo_service.availability.id
        name   = module.slo_service.availability.name
        target = var.availability_target
      }
      traffic = {
        id     = module.slo_service.traffic.id
        name   = module.slo_service.traffic.name
        target = var.traffic_target
      }
      errors = {
        id     = module.slo_service.errors.id
        name   = module.slo_service.errors.name
        target = var.error_rate_target
      }
    }
    guardian = {
      enabled = var.enable_guardian
      id      = try(dynatrace_site_reliability_guardian.service[0].id, null)
      name    = var.enable_guardian ? local.guardian_name : null
    }
  }
}

output "guardian_id" {
  description = "ID of the Site Reliability Guardian"
  value       = try(dynatrace_site_reliability_guardian.service[0].id, null)
}
