resource "google_compute_router_peer" "this" {
  for_each                           = nonsensitive(toset(keys(var.peers)))
  advertise_mode                     = var.peers[each.key].advertise_mode
  advertised_groups                  = var.peers[each.key].advertised_groups
  advertised_route_priority          = var.peers[each.key].advertised_route_priority
  custom_learned_route_priority      = var.peers[each.key].custom_learned_route_priority
  deletion_policy                    = var.peers[each.key].deletion_policy
  enable                             = var.peers[each.key].enable
  enable_ipv4                        = var.peers[each.key].enable_ipv4
  enable_ipv6                        = var.peers[each.key].enable_ipv6
  export_policies                    = var.peers[each.key].export_policies
  import_policies                    = var.peers[each.key].import_policies
  interface                          = var.peers[each.key].interface_key != null ? google_compute_router_interface.this[var.peers[each.key].interface_key].name : var.peers[each.key].interface
  ip_address                         = var.peers[each.key].ip_address
  ipv4_nexthop_address               = var.peers[each.key].ipv4_nexthop_address
  ipv6_nexthop_address               = var.peers[each.key].ipv6_nexthop_address
  name                               = local.naming.peers[each.key]
  peer_asn                           = var.peers[each.key].peer_asn
  peer_ip_address                    = var.peers[each.key].peer_ip_address
  peer_ipv4_nexthop_address          = var.peers[each.key].peer_ipv4_nexthop_address
  peer_ipv6_nexthop_address          = var.peers[each.key].peer_ipv6_nexthop_address
  project                            = local.peers_context[each.key].project
  region                             = local.peers_context[each.key].region
  router                             = local.peers_context[each.key].router
  router_appliance_instance          = var.peers[each.key].router_appliance_instance
  zero_advertised_route_priority     = var.peers[each.key].zero_advertised_route_priority
  zero_custom_learned_route_priority = var.peers[each.key].zero_custom_learned_route_priority
  dynamic "advertised_ip_ranges" {
    for_each = var.peers[each.key].advertised_ip_ranges
    iterator = item_advertised_ip_ranges
    content {
      description = item_advertised_ip_ranges.value.description
      range       = item_advertised_ip_ranges.value.range
    }
  }
  dynamic "bfd" {
    for_each = var.peers[each.key].bfd == null ? [] : [
      var.peers[each.key].bfd,
    ]
    iterator = item_bfd
    content {
      min_receive_interval        = item_bfd.value.min_receive_interval
      min_transmit_interval       = item_bfd.value.min_transmit_interval
      multiplier                  = item_bfd.value.multiplier
      session_initialization_mode = item_bfd.value.session_initialization_mode
    }
  }
  dynamic "custom_learned_ip_ranges" {
    for_each = var.peers[each.key].custom_learned_ip_ranges
    iterator = item_custom_learned_ip_ranges
    content {
      range = item_custom_learned_ip_ranges.value.range
    }
  }
  dynamic "md5_authentication_key" {
    for_each = var.peers[each.key].md5_authentication_key == null ? [] : [
      var.peers[each.key].md5_authentication_key,
    ]
    iterator = item_md5_authentication_key
    content {
      key  = sensitive(item_md5_authentication_key.value.key)
      name = item_md5_authentication_key.value.name
    }
  }
  dynamic "timeouts" {
    for_each = var.peers[each.key].timeouts == null ? [] : [
      var.peers[each.key].timeouts,
    ]
    iterator = item_timeouts
    content {
      create = item_timeouts.value.create
      delete = item_timeouts.value.delete
      update = item_timeouts.value.update
    }
  }
  lifecycle {
    precondition {
      condition = var.peers[each.key].interface_key == null ? true : (
        local.peers_context[each.key].router == google_compute_router_interface.this[var.peers[each.key].interface_key].router &&
        local.peers_context[each.key].project == google_compute_router_interface.this[var.peers[each.key].interface_key].project &&
        local.peers_context[each.key].region == google_compute_router_interface.this[var.peers[each.key].interface_key].region
      )
      error_message = "A peer and its interface must belong to the same router, project and region."
    }
  }
}
