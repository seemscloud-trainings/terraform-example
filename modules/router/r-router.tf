resource "google_compute_router" "this" {
  for_each                      = nonsensitive(toset(keys(var.routers)))
  deletion_policy               = var.routers[each.key].deletion_policy
  description                   = var.routers[each.key].description
  encrypted_interconnect_router = var.routers[each.key].encrypted_interconnect_router
  name                          = local.naming.routers[each.key]
  ncc_gateway                   = var.routers[each.key].ncc_gateway
  network                       = var.routers[each.key].network
  project                       = var.routers[each.key].project != null ? var.routers[each.key].project : var.project
  region                        = var.routers[each.key].region != null ? var.routers[each.key].region : var.region
  dynamic "bgp" {
    for_each = var.routers[each.key].bgp == null ? [] : [var.routers[each.key].bgp]
    iterator = item_bgp
    content {
      advertise_mode     = item_bgp.value.advertise_mode
      advertised_groups  = item_bgp.value.advertised_groups
      asn                = item_bgp.value.asn
      identifier_range   = item_bgp.value.identifier_range
      keepalive_interval = item_bgp.value.keepalive_interval
      dynamic "advertised_ip_ranges" {
        for_each = item_bgp.value.advertised_ip_ranges
        iterator = item_advertised_ip_ranges
        content {
          description = item_advertised_ip_ranges.value.description
          range       = item_advertised_ip_ranges.value.range
        }
      }
    }
  }
  dynamic "md5_authentication_keys" {
    for_each = var.routers[each.key].md5_authentication_keys == null ? [] : [var.routers[each.key].md5_authentication_keys]
    iterator = item_md5_authentication_keys
    content {
      key  = sensitive(item_md5_authentication_keys.value.key)
      name = item_md5_authentication_keys.value.name
    }
  }
  dynamic "params" {
    for_each = var.routers[each.key].params == null ? [] : [var.routers[each.key].params]
    iterator = item_params
    content {
      resource_manager_tags = item_params.value.resource_manager_tags
    }
  }
  dynamic "timeouts" {
    for_each = var.routers[each.key].timeouts == null ? [] : [var.routers[each.key].timeouts]
    iterator = item_timeouts
    content {
      create = item_timeouts.value.create
      delete = item_timeouts.value.delete
      update = item_timeouts.value.update
    }
  }
}
