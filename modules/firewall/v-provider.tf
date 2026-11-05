variable "project" {
  type        = string
  nullable    = false
  description = "Default GCP project; individual resources may override it."
}

variable "region" {
  type        = string
  default     = null
  description = "Optional Google provider region setting."
}

variable "impersonate_service_account" {
  type        = string
  default     = null
  description = "Optional Google provider impersonate_service_account setting."
}

variable "impersonate_service_account_delegates" {
  type        = list(string)
  default     = null
  description = "Optional Google provider impersonate_service_account_delegates setting."
}

variable "billing_project" {
  type        = string
  default     = null
  description = "Optional Google provider billing_project setting."
}

variable "user_project_override" {
  type        = bool
  default     = null
  description = "Optional Google provider user_project_override setting."
}

variable "default_labels" {
  type        = map(string)
  default     = null
  description = "Optional Google provider default_labels setting."
}

variable "request_timeout" {
  type        = string
  default     = null
  description = "Optional Google provider request_timeout setting."
}

variable "request_reason" {
  type        = string
  default     = null
  description = "Optional Google provider request_reason setting."
}

variable "universe_domain" {
  type        = string
  default     = null
  description = "Optional Google provider universe_domain setting."
}

variable "compute_custom_endpoint" {
  type        = string
  default     = null
  description = "Optional Google provider compute_custom_endpoint setting."
}
