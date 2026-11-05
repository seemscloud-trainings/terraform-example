resource "google_compute_router" "this" {
  deletion_policy               = var.router.deletion_policy
  description                   = var.router.description
  encrypted_interconnect_router = var.router.encrypted_interconnect_router
  name                          = local.naming.router
  ncc_gateway                   = var.router.ncc_gateway
  network                       = var.router.network
  project                       = var.router.project != null ? var.router.project : var.project
  region                        = var.router.region != null ? var.router.region : var.region
  dynamic "bgp" {
    for_each = var.router.bgp == null ? [] : [
      var.router.bgp,
    ]
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
    for_each = var.router.md5_authentication_keys == null ? [] : [
      var.router.md5_authentication_keys,
    ]
    iterator = item_md5_authentication_keys
    content {
      key  = sensitive(item_md5_authentication_keys.value.key)
      name = item_md5_authentication_keys.value.name
    }
  }
  dynamic "params" {
    for_each = var.router.params == null ? [] : [
      var.router.params,
    ]
    iterator = item_params
    content {
      resource_manager_tags = item_params.value.resource_manager_tags
    }
  }
  dynamic "timeouts" {
    for_each = var.router.timeouts == null ? [] : [
      var.router.timeouts,
    ]
    iterator = item_timeouts
    content {
      create = item_timeouts.value.create
      delete = item_timeouts.value.delete
      update = item_timeouts.value.update
    }
  }
}
