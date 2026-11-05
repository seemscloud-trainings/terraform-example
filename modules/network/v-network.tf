variable "network" {
  type = object({
    auto_create_subnetworks                   = optional(bool, false)
    bgp_always_compare_med                    = optional(bool)
    bgp_best_path_selection_mode              = optional(string)
    bgp_inter_region_cost                     = optional(string)
    delete_bgp_always_compare_med             = optional(bool)
    delete_default_routes_on_create           = optional(bool)
    deletion_policy                           = optional(string)
    description                               = optional(string)
    enable_ula_internal_ipv6                  = optional(bool)
    internal_ipv6_range                       = optional(string)
    mtu                                       = optional(number)
    name                                      = string
    network_firewall_policy_enforcement_order = optional(string)
    network_profile                           = optional(string)
    project                                   = optional(string)
    routing_mode                              = optional(string)
    params = optional(object({
      resource_manager_tags = optional(map(string))
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
  })
  nullable    = false
  description = "VPC settings. Name is supplied unchanged by the caller; custom subnet mode is the default."
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", var.network.name))
    error_message = "network.name must be a valid GCP resource name (1-63 lowercase letters/digits/hyphens)."
  }
  validation {
    condition     = var.network.routing_mode == null ? true : contains(["REGIONAL", "GLOBAL"], var.network.routing_mode)
    error_message = "routing_mode must be REGIONAL or GLOBAL."
  }
}
