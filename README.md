# Dynatrace SLO Terraform

This Terraform project manages Dynatrace Service Level Objectives (SLOs) based on the LATE metrics (Latency, Availability, Traffic, Errors) for any monitored service and optionally links them to a Site Reliability Guardian policy.

## Overview

The configuration creates four SLOs in Dynatrace and (optionally) a Site Reliability Guardian that validates them before deployments:

1. **Latency SLO** - Monitors response time performance
2. **Availability SLO** - Tracks service uptime and success rate
3. **Traffic SLO** - Measures request throughput
4. **Error Rate SLO** - Monitors the percentage of failed requests
5. **Site Reliability Guardian** - Aggregates the four SLOs into a deployment readiness check

## Prerequisites

- Terraform >= 1.0
- Dynatrace account with API access
- Dynatrace API token with SLO, Settings read/write permissions

### Creating a Dynatrace API Token

1. Log into your Dynatrace environment
2. Navigate to **Settings > Integration > Dynatrace API**
3. Click **Generate token**
4. Provide a name and enable the following scopes:
   - `slo.read`
   - `slo.write`
   - `metrics.read`
   - `settings.read`
   - `settings.write`
5. Copy the generated token

## Setup

1. Clone or download this project

2. Copy the example tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Edit `terraform.tfvars` and update with your values:
   - `dynatrace_environment_url`: Your Dynatrace environment URL
   - `dynatrace_api_token`: Your API token
   - Adjust SLO targets and thresholds as needed
   - Optionally configure Site Reliability Guardian metadata

4. Initialize Terraform:
   ```bash
   terraform init
   ```

5. Review the planned changes:
   ```bash
   terraform plan
   ```

6. Apply the configuration:
   ```bash
   terraform apply
   ```

## Configuration

### Variables

All configurable variables are defined in `variables.tf`. Key variables include:

- **service_name**: Name of the service the SLOs apply to (default: "TodoService")
- **timeframe**: Evaluation period (default: "-1w" for 1 week)

#### Latency SLO
- **latency_target**: Target % (default: 95.0)
- **latency_warning**: Warning threshold (default: 97.0)
- **latency_threshold_ms**: Max acceptable latency in ms (default: 500)
- **latency_percentile**: Which percentile to measure (default: 95)

#### Availability SLO
- **availability_target**: Target % (default: 99.9)
- **availability_warning**: Warning threshold (default: 99.95)

#### Traffic SLO
- **traffic_target**: Target % (default: 90.0)
- **traffic_warning**: Warning threshold (default: 95.0)
- **traffic_threshold_rpm**: Expected requests per minute (default: 100)

#### Error Rate SLO
- **error_rate_target**: Target % of successful requests (default: 99.5)
- **error_rate_warning**: Warning threshold (default: 99.8)

#### Site Reliability Guardian
- **enable_guardian**: Toggle guardian creation (default: `true`)
- **guardian_name**: Override guardian name (default: `"<service_name> Guardian"`)
- **guardian_description**: Optional description (default provides context)
- **guardian_event_kind**: Storage type for evaluation events (`BIZ_EVENT` or `SDLC_EVENT`)
- **guardian_tags**: Additional guardian tags (default: empty)

### Customization

Each SLO is generated from a single reusable module, so you can adjust thresholds and naming conventions in one place. Common changes include:

1. Overriding the defaults in `terraform.tfvars`.
2. Running `terraform plan` to preview the update.
3. Applying the change with `terraform apply`.

To target a different service:
```hcl
service_name = "MyOtherService"
```

## Outputs

After applying, Terraform outputs:

- Individual SLO IDs for each metric
- Site Reliability Guardian ID (if enabled)
- Summary object with all SLO and guardian details (including targets and guardian metadata)

View outputs:
```bash
terraform output
```

## Security

- **Never commit** `terraform.tfvars` containing your API token
- The `dynatrace_api_token` variable is marked as sensitive
- Consider using environment variables or secret management:
  ```bash
  export TF_VAR_dynatrace_api_token="your-token"
  export TF_VAR_dynatrace_environment_url="https://your-env.live.dynatrace.com"
  ```

## File Structure

```
dynatrace-slo-terraform/
├── main.tf                    # SLO resources and Site Reliability Guardian
├── variables.tf               # Variable declarations
├── outputs.tf                 # Output definitions
├── terraform.tfvars.example   # Example configuration
├── modules/
│   └── slo_service/           # Module managing individual SLO resources and outputs
└── README.md                  # Documentation
```

## Maintenance

### Updating SLOs

Modify values in `terraform.tfvars` and run:
```bash
terraform apply
```

### Destroying SLOs

To remove all SLOs:
```bash
terraform destroy
```

## Troubleshooting

- **Authentication errors**: Verify API token has correct permissions
- **Service not found**: Ensure service name exactly matches Dynatrace service entity name
- **Metric errors**: Check that the service has enough data for the specified timeframe

## References

- [Dynatrace Terraform Provider Documentation](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs)
- [Dynatrace SLO Documentation](https://www.dynatrace.com/support/help/how-to-use-dynatrace/service-level-objectives)
- [Dynatrace Metrics Documentation](https://www.dynatrace.com/support/help/how-to-use-dynatrace/metrics)
