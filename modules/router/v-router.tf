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
  validation {
    condition     = alltrue([for v in values(var.routers) : can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", v.name))])
    error_message = "Names must be valid GCP resource names (1-63 lowercase letters/digits/hyphens)."
  }
}
