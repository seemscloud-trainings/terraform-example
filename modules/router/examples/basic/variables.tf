variable "provider_config" {
  type = object({
    project                               = string
    region                                = optional(string)
    impersonate_service_account           = optional(string)
    impersonate_service_account_delegates = optional(list(string))
    billing_project                       = optional(string)
    user_project_override                 = optional(bool)
    default_labels                        = optional(map(string))
    request_timeout                       = optional(string)
    request_reason                        = optional(string)
    universe_domain                       = optional(string)
    compute_custom_endpoint               = optional(string)
  })
  nullable    = false
  description = "Provider defaults. Use ADC or impersonation; never commit credentials."
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
