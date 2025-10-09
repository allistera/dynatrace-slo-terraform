locals {
  slo_targets = {
    latency      = var.latency_target
    availability = var.availability_target
    traffic      = var.traffic_target
    errors       = var.error_rate_target
  }

  slo_summary_values = {
    for key, slo in module.slo_service.slos :
    key => {
      id     = slo.id
      name   = slo.name
      target = lookup(local.slo_targets, key, null)
    }
  }
}

output "latency_slo_id" {
  description = "ID of the latency SLO"
  value       = try(module.slo_service.slos["latency"].id, null)
}

output "availability_slo_id" {
  description = "ID of the availability SLO"
  value       = try(module.slo_service.slos["availability"].id, null)
}

output "traffic_slo_id" {
  description = "ID of the traffic SLO"
  value       = try(module.slo_service.slos["traffic"].id, null)
}

output "error_rate_slo_id" {
  description = "ID of the error rate SLO"
  value       = try(module.slo_service.slos["errors"].id, null)
}

output "slo_summary" {
  description = "Summary of all created SLOs"
  value = {
    service_name = var.service_name
    slos         = local.slo_summary_values
    guardian = {
      enabled = length(dynatrace_site_reliability_guardian.service) > 0
      id      = try(dynatrace_site_reliability_guardian.service[0].id, null)
      name    = length(dynatrace_site_reliability_guardian.service) > 0 ? local.guardian_name : null
    }
  }
}

output "guardian_id" {
  description = "ID of the Site Reliability Guardian"
  value       = try(dynatrace_site_reliability_guardian.service[0].id, null)
}
