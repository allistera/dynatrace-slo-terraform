# Dynatrace SLO Terraform - TodoService LATE Metrics

This Terraform project manages Dynatrace SLOs based on the LATE metrics (Latency, Availability, Traffic, Errors) for the TodoService.

## Overview

The project creates four SLOs in Dynatrace:

1. **Latency SLO** - Monitors response time performance
2. **Availability SLO** - Tracks service uptime and success rate
3. **Traffic SLO** - Measures request throughput
4. **Error Rate SLO** - Monitors the percentage of failed requests

## Prerequisites

- Terraform >= 1.0
- Dynatrace account with API access
- Dynatrace API token with SLO write permissions

### Creating a Dynatrace API Token

1. Log into your Dynatrace environment
2. Navigate to **Settings > Integration > Dynatrace API**
3. Click **Generate token**
4. Provide a name and enable the following scopes:
   - `slo.read`
   - `slo.write`
   - `metrics.read`
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

- **service_name**: Name of the service (default: "TodoService")
- **timeframe**: Evaluation period (default: "-1w" for 1 week)

#### Latency SLO
- **latency_target**: Target % (default: 95.0)
- **latency_threshold_ms**: Max acceptable latency in ms (default: 500)
- **latency_percentile**: Which percentile to measure (default: 95)

#### Availability SLO
- **availability_target**: Target % (default: 99.9)

#### Traffic SLO
- **traffic_target**: Target % (default: 90.0)
- **traffic_threshold_rpm**: Expected requests per minute (default: 100)

#### Error Rate SLO
- **error_rate_target**: Target % of successful requests (default: 99.5)

### Customization

To modify SLO parameters:

1. Edit values in `terraform.tfvars`
2. Run `terraform plan` to preview changes
3. Run `terraform apply` to apply changes

To change the service name:
```hcl
service_name = "MyOtherService"
```

## Outputs

After applying, Terraform outputs:

- Individual SLO IDs for each metric
- Summary object with all SLO details

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
├── main.tf                    # SLO resource definitions
├── variables.tf               # Variable declarations
├── outputs.tf                 # Output definitions
├── terraform.tfvars.example   # Example configuration
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
