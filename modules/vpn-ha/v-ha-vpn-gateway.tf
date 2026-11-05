variable "gateway" {
  type = object({
    deletion_policy    = optional(string)
    description        = optional(string)
    gateway_ip_version = optional(string)
    labels             = optional(map(string))
    name               = string
    network            = string
    project            = optional(string)
    region             = optional(string)
    stack_type         = optional(string)
    params = optional(object({
      resource_manager_tags = optional(map(string))
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
    vpn_interfaces = optional(map(object({
      id                      = optional(number)
      interconnect_attachment = optional(string)
    })), {})
  })
  nullable    = false
  description = "One HA VPN gateway; the explicit name is used unchanged."
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", var.gateway.name))
    error_message = "Names must be valid GCP resource names (1-63 lowercase letters/digits/hyphens)."
  }
}
