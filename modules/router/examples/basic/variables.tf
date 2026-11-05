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


variable "routers" {
  type = map(object({
    deletion_policy               = optional(string)
    description                   = optional(string)
    encrypted_interconnect_router = optional(bool)
    name                          = string
    ncc_gateway                   = optional(string)
    network                       = optional(string)
    project                       = optional(string)
    region                        = optional(string)
    bgp = optional(object({
      advertise_mode     = optional(string)
      advertised_groups  = optional(list(string))
      asn                = number
      identifier_range   = optional(string)
      keepalive_interval = optional(number)
      advertised_ip_ranges = optional(map(object({
        description = optional(string)
        range       = string
      })), {})
    }))
    md5_authentication_keys = optional(object({
      key  = string
      name = string
    }))
    params = optional(object({
      resource_manager_tags = optional(map(string))
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  nullable    = false
  description = "router configurations keyed by stable logical identifiers; every name is supplied unchanged by the caller."
}
