resource "google_network_connectivity_spoke" "this" {
  deletion_policy = var.spoke.deletion_policy
  description     = var.spoke.description
  group           = var.spoke.group
  hub             = var.spoke.hub
  labels          = var.spoke.labels
  location        = var.spoke.location
  name            = local.naming.spoke
  project         = var.spoke.project != null ? var.spoke.project : var.project
  dynamic "gateway" {
    for_each = var.spoke.gateway == null ? [] : [var.spoke.gateway]
    iterator = item_gateway
    content {
      capacity = item_gateway.value.capacity
      dynamic "ip_range_reservations" {
        for_each = item_gateway.value.ip_range_reservations
        iterator = item_gateway_ip_range_reservations
        content {
          ip_range = item_gateway_ip_range_reservations.value.ip_range
        }
      }
    }
  }
  dynamic "linked_interconnect_attachments" {
    for_each = var.spoke.linked_interconnect_attachments == null ? [] : [var.spoke.linked_interconnect_attachments]
    iterator = item_linked_interconnect_attachments
    content {
      exclude_export_ranges      = item_linked_interconnect_attachments.value.exclude_export_ranges
      exclude_import_ranges      = item_linked_interconnect_attachments.value.exclude_import_ranges
      include_export_ranges      = item_linked_interconnect_attachments.value.include_export_ranges
      include_import_ranges      = item_linked_interconnect_attachments.value.include_import_ranges
      site_to_site_data_transfer = item_linked_interconnect_attachments.value.site_to_site_data_transfer
      uris                       = item_linked_interconnect_attachments.value.uris
    }
  }
  dynamic "linked_producer_vpc_network" {
    for_each = var.spoke.linked_producer_vpc_network == null ? [] : [var.spoke.linked_producer_vpc_network]
    iterator = item_linked_producer_vpc_network
    content {
      exclude_export_ranges = item_linked_producer_vpc_network.value.exclude_export_ranges
      include_export_ranges = item_linked_producer_vpc_network.value.include_export_ranges
      network               = item_linked_producer_vpc_network.value.network
      peering               = item_linked_producer_vpc_network.value.peering
    }
  }
  dynamic "linked_router_appliance_instances" {
    for_each = var.spoke.linked_router_appliance_instances == null ? [] : [var.spoke.linked_router_appliance_instances]
    iterator = item_linked_router_appliance_instances
    content {
      exclude_export_ranges      = item_linked_router_appliance_instances.value.exclude_export_ranges
      exclude_import_ranges      = item_linked_router_appliance_instances.value.exclude_import_ranges
      include_export_ranges      = item_linked_router_appliance_instances.value.include_export_ranges
      include_import_ranges      = item_linked_router_appliance_instances.value.include_import_ranges
      site_to_site_data_transfer = item_linked_router_appliance_instances.value.site_to_site_data_transfer
      dynamic "instances" {
        for_each = item_linked_router_appliance_instances.value.instances
        iterator = item_linked_router_appliance_instances_instances
        content {
          ip_address      = item_linked_router_appliance_instances_instances.value.ip_address
          virtual_machine = item_linked_router_appliance_instances_instances.value.virtual_machine
        }
      }
    }
  }
  dynamic "linked_vpc_network" {
    for_each = var.spoke.linked_vpc_network == null ? [] : [var.spoke.linked_vpc_network]
    iterator = item_linked_vpc_network
    content {
      exclude_export_ranges = item_linked_vpc_network.value.exclude_export_ranges
      include_export_ranges = item_linked_vpc_network.value.include_export_ranges
      uri                   = item_linked_vpc_network.value.uri
    }
  }
  dynamic "linked_vpn_tunnels" {
    for_each = var.spoke.linked_vpn_tunnels == null ? [] : [var.spoke.linked_vpn_tunnels]
    iterator = item_linked_vpn_tunnels
    content {
      exclude_export_ranges      = item_linked_vpn_tunnels.value.exclude_export_ranges
      exclude_import_ranges      = item_linked_vpn_tunnels.value.exclude_import_ranges
      include_export_ranges      = item_linked_vpn_tunnels.value.include_export_ranges
      include_import_ranges      = item_linked_vpn_tunnels.value.include_import_ranges
      site_to_site_data_transfer = item_linked_vpn_tunnels.value.site_to_site_data_transfer
      uris                       = item_linked_vpn_tunnels.value.uris
    }
  }
  dynamic "timeouts" {
    for_each = var.spoke.timeouts == null ? [] : [var.spoke.timeouts]
    iterator = item_timeouts
    content {
      create = item_timeouts.value.create
      delete = item_timeouts.value.delete
      update = item_timeouts.value.update
    }
  }
}
