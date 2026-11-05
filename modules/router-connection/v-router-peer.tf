variable "peers" {
  type = map(object({
    advertise_mode                     = optional(string)
    advertised_groups                  = optional(list(string))
    advertised_route_priority          = optional(number)
    custom_learned_route_priority      = optional(number)
    deletion_policy                    = optional(string)
    enable                             = optional(bool)
    enable_ipv4                        = optional(bool)
    enable_ipv6                        = optional(bool)
    export_policies                    = optional(list(string))
    import_policies                    = optional(list(string))
    interface                          = optional(string)
    ip_address                         = optional(string)
    ipv4_nexthop_address               = optional(string)
    ipv6_nexthop_address               = optional(string)
    name                               = string
    peer_asn                           = number
    peer_ip_address                    = optional(string)
    peer_ipv4_nexthop_address          = optional(string)
    peer_ipv6_nexthop_address          = optional(string)
    project                            = optional(string)
    region                             = optional(string)
    router_appliance_instance          = optional(string)
    zero_advertised_route_priority     = optional(bool)
    zero_custom_learned_route_priority = optional(bool)
    advertised_ip_ranges = optional(map(object({
      description = optional(string)
      range       = string
    })), {})
    bfd = optional(object({
      min_receive_interval        = optional(number)
      min_transmit_interval       = optional(number)
      multiplier                  = optional(number)
      session_initialization_mode = string
    }))
    custom_learned_ip_ranges = optional(map(object({
      range = string
    })), {})
    md5_authentication_key = optional(object({
      key  = string
      name = string
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
    interface_key = optional(string)
  }))
  default     = {}
  nullable    = false
  description = "router_peer configurations keyed by stable logical identifiers; every name is supplied unchanged by the caller."
  validation {
    condition = alltrue([
      for v in values(var.peers) : can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", v.name))
    ])
    error_message = "Names must be valid GCP resource names (1-63 lowercase letters/digits/hyphens)."
  }
  validation {
    condition = alltrue([
      for v in values(var.peers) : (v.interface != null) != (v.interface_key != null)
    ])
    error_message = "Supply exactly one of interface or interface_key."
  }
  validation {
    condition = alltrue([
      for v in values(var.peers) : v.interface_key == null ? true : contains(keys(var.interfaces), v.interface_key)
    ])
    error_message = "interface_key must identify an interface created by this module invocation."
  }
}
