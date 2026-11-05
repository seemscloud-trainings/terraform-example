variable "spoke" {
  type = object({
    deletion_policy = optional(string)
    description     = optional(string)
    group           = optional(string)
    hub             = string
    labels          = optional(map(string))
    location        = string
    name            = string
    project         = optional(string)
    gateway = optional(object({
      capacity = string
      ip_range_reservations = map(object({
        ip_range = string
      }))
    }))
    linked_interconnect_attachments = optional(object({
      exclude_export_ranges      = optional(list(string))
      exclude_import_ranges      = optional(list(string))
      include_export_ranges      = optional(list(string))
      include_import_ranges      = optional(list(string))
      site_to_site_data_transfer = bool
      uris                       = list(string)
    }))
    linked_producer_vpc_network = optional(object({
      exclude_export_ranges = optional(list(string))
      include_export_ranges = optional(list(string))
      network               = string
      peering               = string
    }))
    linked_router_appliance_instances = optional(object({
      exclude_export_ranges      = optional(list(string))
      exclude_import_ranges      = optional(list(string))
      include_export_ranges      = optional(list(string))
      include_import_ranges      = optional(list(string))
      site_to_site_data_transfer = bool
      instances = map(object({
        ip_address      = string
        virtual_machine = string
      }))
    }))
    linked_vpc_network = optional(object({
      exclude_export_ranges = optional(list(string))
      include_export_ranges = optional(list(string))
      uri                   = string
    }))
    linked_vpn_tunnels = optional(object({
      exclude_export_ranges      = optional(list(string))
      exclude_import_ranges      = optional(list(string))
      include_export_ranges      = optional(list(string))
      include_import_ranges      = optional(list(string))
      site_to_site_data_transfer = bool
      uris                       = list(string)
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
  })
  nullable = false
  validation {
    condition = length([
      for link in [
        var.spoke.gateway,
        var.spoke.linked_interconnect_attachments,
        var.spoke.linked_producer_vpc_network,
        var.spoke.linked_router_appliance_instances,
        var.spoke.linked_vpc_network,
        var.spoke.linked_vpn_tunnels,
      ] : link if link != null
    ]) == 1
    error_message = "A spoke must select exactly one linked resource type."
  }
  validation {
    condition     = var.spoke.linked_vpc_network == null && var.spoke.linked_producer_vpc_network == null ? true : var.spoke.location == "global"
    error_message = "VPC spokes must use location global."
  }
}
