locals {
  slo_module_outputs = {
    latency      = module.slo_service.latency
    availability = module.slo_service.availability
    traffic      = module.slo_service.traffic
    errors       = module.slo_service.errors
  }

  slo_targets = {
    latency      = var.latency_target
    availability = var.availability_target
    traffic      = var.traffic_target
    errors       = var.error_rate_target
  }

  slo_summary_slos = {
    for key, target in local.slo_targets :
    key => merge(
      {
        target = target
      },
      local.slo_module_outputs[key] != null ? {
        id   = try(local.slo_module_outputs[key].id, null)
        name = try(local.slo_module_outputs[key].name, null)
      } : {}
    )
  }
}

output "latency_slo_id" {
  description = "ID of the latency SLO"
  value       = try(local.slo_module_outputs.latency.id, null)
}

output "availability_slo_id" {
  description = "ID of the availability SLO"
  value       = try(local.slo_module_outputs.availability.id, null)
}

output "traffic_slo_id" {
  description = "ID of the traffic SLO"
  value       = try(local.slo_module_outputs.traffic.id, null)
}

output "error_rate_slo_id" {
  description = "ID of the error rate SLO"
  value       = try(local.slo_module_outputs.errors.id, null)
}

output "slo_summary" {
  description = "Summary of all created SLOs"
  value = {
    service_name = var.service_name
    slos = local.slo_summary_slos
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
