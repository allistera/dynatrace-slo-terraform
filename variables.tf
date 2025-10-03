variable "dynatrace_environment_url" {
  description = "Dynatrace environment URL (e.g., https://abc12345.live.dynatrace.com)"
  type        = string
}

variable "dynatrace_api_token" {
  description = "Dynatrace API token with SLO write permissions"
  type        = string
  sensitive   = true
}

variable "service_name" {
  description = "Name of the service to create SLOs for"
  type        = string
  default     = "TodoService"
}

variable "timeframe" {
  description = "Timeframe for SLO evaluation (e.g., -1w for 1 week)"
  type        = string
  default     = "-1w"
}

# Latency SLO variables
variable "latency_target" {
  description = "Target percentage for latency SLO (e.g., 95.0 means 95%)"
  type        = number
  default     = 95.0
}

variable "latency_warning" {
  description = "Warning threshold for latency SLO"
  type        = number
  default     = 97.0
}

variable "latency_threshold_ms" {
  description = "Latency threshold in milliseconds"
  type        = number
  default     = 500
}

variable "latency_percentile" {
  description = "Percentile to use for latency measurement (50, 90, 95, 99)"
  type        = number
  default     = 95
}

# Availability SLO variables
variable "availability_target" {
  description = "Target percentage for availability SLO"
  type        = number
  default     = 99.9
}

variable "availability_warning" {
  description = "Warning threshold for availability SLO"
  type        = number
  default     = 99.95
}

# Traffic SLO variables
variable "traffic_target" {
  description = "Target percentage for traffic throughput SLO"
  type        = number
  default     = 90.0
}

variable "traffic_warning" {
  description = "Warning threshold for traffic SLO"
  type        = number
  default     = 95.0
}

variable "traffic_threshold_rpm" {
  description = "Expected traffic threshold in requests per minute"
  type        = number
  default     = 100
}

# Error Rate SLO variables
variable "error_rate_target" {
  description = "Target percentage for error rate SLO (percentage of successful requests)"
  type        = number
  default     = 99.5
}

variable "error_rate_warning" {
  description = "Warning threshold for error rate SLO"
  type        = number
  default     = 99.8
}

# Synthetic monitoring variables
variable "service_url" {
  description = "URL of the service to monitor"
  type        = string
  default     = "http://3.250.34.74/"
}

variable "synthetic_locations" {
  description = "List of Dynatrace synthetic location IDs"
  type        = list(string)
  default     = ["GEOLOCATION-9999999999999999"]
}
