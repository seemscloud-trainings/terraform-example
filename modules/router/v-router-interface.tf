variable "interfaces" {
  type = map(object({
    deletion_policy         = optional(string)
    interconnect_attachment = optional(string)
    ip_range                = optional(string)
    ip_version              = optional(string)
    name                    = string
    private_ip_address      = optional(string)
    project                 = optional(string)
    redundant_interface     = optional(string)
    region                  = optional(string)
    router                  = optional(string)
    subnetwork              = optional(string)
    vpn_tunnel              = optional(string)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
    }))
    router_key = optional(string)
  }))
  default     = {}
  nullable    = false
  description = "router_interface configurations keyed by stable logical identifiers; every name is supplied unchanged by the caller."
  validation {
    condition     = alltrue([for v in values(var.interfaces) : can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", v.name))])
    error_message = "Names must be valid GCP resource names (1-63 lowercase letters/digits/hyphens)."
  }
  validation {
    condition     = alltrue([for v in values(var.interfaces) : (v.router != null) != (v.router_key != null)])
    error_message = "Supply exactly one of router or router_key."
  }
  validation {
    condition     = alltrue([for v in values(var.interfaces) : v.router_key == null ? true : contains(keys(var.routers), v.router_key)])
    error_message = "router_key must identify a router created by this module invocation."
  }
}
