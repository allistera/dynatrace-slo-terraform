variable "service_name" {
  description = "Name of the service to create SLOs for"
  type        = string
}

variable "timeframe" {
  description = "Timeframe for SLO evaluation"
  type        = string
}

variable "latency_target" {
  description = "Target percentage for latency SLO"
  type        = number
}

variable "latency_warning" {
  description = "Warning threshold for latency SLO"
  type        = number
}

variable "latency_threshold_ms" {
  description = "Latency threshold in milliseconds"
  type        = number
}

variable "latency_percentile" {
  description = "Percentile to use for latency measurement"
  type        = number
}

variable "availability_target" {
  description = "Target percentage for availability SLO"
  type        = number
}

variable "availability_warning" {
  description = "Warning threshold for availability SLO"
  type        = number
}

variable "traffic_target" {
  description = "Target percentage for traffic throughput SLO"
  type        = number
}

variable "traffic_warning" {
  description = "Warning threshold for traffic SLO"
  type        = number
}

variable "traffic_threshold_rpm" {
  description = "Expected traffic threshold in requests per minute"
  type        = number
}

variable "error_rate_target" {
  description = "Target percentage for error rate SLO"
  type        = number
}

variable "error_rate_warning" {
  description = "Warning threshold for error rate SLO"
  type        = number
}
