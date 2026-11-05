resource "google_compute_router_interface" "this" {
  for_each                = nonsensitive(toset(keys(var.interfaces)))
  deletion_policy         = var.interfaces[each.key].deletion_policy
  interconnect_attachment = var.interfaces[each.key].interconnect_attachment
  ip_range                = var.interfaces[each.key].ip_range
  ip_version              = var.interfaces[each.key].ip_version
  name                    = local.naming.interfaces[each.key]
  private_ip_address      = var.interfaces[each.key].private_ip_address
  project                 = local.interfaces_context[each.key].project
  redundant_interface     = var.interfaces[each.key].redundant_interface
  region                  = local.interfaces_context[each.key].region
  router                  = local.interfaces_context[each.key].router
  subnetwork              = var.interfaces[each.key].subnetwork
  vpn_tunnel              = var.interfaces[each.key].vpn_tunnel
  dynamic "timeouts" {
    for_each = var.interfaces[each.key].timeouts == null ? [] : [
      var.interfaces[each.key].timeouts,
    ]
    iterator = item_timeouts
    content {
      create = item_timeouts.value.create
      delete = item_timeouts.value.delete
    }
  }
}
