variable "peering" {
  type = object({
    deletion_policy                     = optional(string)
    export_custom_routes                = optional(bool)
    export_subnet_routes_with_public_ip = optional(bool)
    import_custom_routes                = optional(bool)
    import_subnet_routes_with_public_ip = optional(bool)
    name                                = string
    network                             = string
    peer_network                        = string
    stack_type                          = optional(string)
    update_strategy                     = optional(string)
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  nullable    = false
  description = "One directional VPC peering configuration. Configure the reciprocal side separately."
  validation {
    condition     = var.peering.network != var.peering.peer_network
    error_message = "Local and peer networks must differ."
  }
}
