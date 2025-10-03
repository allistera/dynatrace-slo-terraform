# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/claude-code) when working with code in this repository.

## Project Overview

Terraform configuration for managing Dynatrace SLOs (Service Level Objectives) based on LATE metrics (Latency, Availability, Traffic, Errors) for monitoring services. Uses the Dynatrace Terraform provider to declaratively manage SLOs and synthetic HTTP monitors.

## Common Commands

### Terraform Operations
- `terraform init` - Initialize Terraform (run after cloning)
- `terraform plan` - Preview changes
- `terraform apply` - Apply configuration changes
- `terraform destroy` - Remove all SLOs and monitors
- `terraform output` - View SLO IDs and summary
- `terraform fmt` - Format all .tf files
- `terraform validate` - Validate configuration

### Linting
- `tflint --init` - Initialize TFLint (first time)
- `tflint --recursive --format compact` - Run linter

## Architecture

### Core Resources
Creates four AGGREGATE-type SLOs in Dynatrace using metric expressions:

1. **Latency SLO** ([main.tf:18-29](main.tf#L18-L29))
   - Calculates percentile response time vs threshold
   - Formula: `(100)*(builtin:service.response.time:splitBy():percentile(N))/(threshold_ms)`

2. **Availability SLO** ([main.tf:32-43](main.tf#L32-L43))
   - Measures success rate (total requests - errors) / total requests
   - Formula: `(100)*((total_requests - errors) / total_requests)`

3. **Traffic SLO** ([main.tf:46-57](main.tf#L46-L57))
   - Monitors request rate vs expected throughput
   - Formula: `(100)*(request_rate_per_min)/(threshold_rpm)`

4. **Error Rate SLO** ([main.tf:60-71](main.tf#L60-L71))
   - Tracks percentage of successful requests
   - Formula: `(100) - ((100)*(errors / total_requests))`

### HTTP Synthetic Monitor ([main.tf:74-95](main.tf#L74-L95))
Uptime check with configurable:
- Frequency (default: 5 min)
- Locations (synthetic monitoring locations)
- Validation rules (expects 200-299 status codes)

### Variable Structure
All SLOs follow this pattern:
- `{metric}_target` - Target % SLO value
- `{metric}_warning` - Warning threshold %
- `{metric}_threshold_*` - Metric-specific thresholds (latency_ms, traffic_rpm)

### Configuration Files
- [main.tf](main.tf) - SLO resources and provider config
- [variables.tf](variables.tf) - Variable declarations with defaults
- [outputs.tf](outputs.tf) - Individual SLO IDs + slo_summary object
- `terraform.tfvars` - User values (git-ignored, contains API token)
- `terraform.tfvars.example` - Template for above

## Dynatrace Authentication

Requires API token with scopes:
- `slo.read`
- `slo.write`
- `metrics.read`

Set via `terraform.tfvars` or environment variables:
```bash
export TF_VAR_dynatrace_api_token="your-token"
export TF_VAR_dynatrace_environment_url="https://your-env.live.dynatrace.com"
```

## CI/CD

GitHub Actions workflow ([.github/workflows/terraform-lint.yml](.github/workflows/terraform-lint.yml)) runs on PR/push:
1. `terraform fmt -check -recursive` - Format validation (fails workflow if incorrect)
2. `terraform init -backend=false` - Initialize without backend
3. `terraform validate` - Validate syntax
4. `tflint --recursive` - Lint with rules from [.tflint.hcl](.tflint.hcl)

TFLint enforces:
- Naming conventions
- Documented variables
- Typed variables
- No unused declarations
- No deprecated interpolation

## Key Patterns

- Service name is templated in all SLO names: `"${var.service_name} - {Metric}"`
- All SLOs use same timeframe variable (default: `-1w`)
- Metric expressions use Dynatrace built-in metrics (`builtin:service.*`)
- Warning thresholds are always > target thresholds
