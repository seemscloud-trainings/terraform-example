resource "google_compute_ha_vpn_gateway" "this" {
  for_each           = nonsensitive(toset(keys(var.gateways)))
  deletion_policy    = var.gateways[each.key].deletion_policy
  description        = var.gateways[each.key].description
  gateway_ip_version = var.gateways[each.key].gateway_ip_version
  labels             = var.gateways[each.key].labels
  name               = local.naming.gateways[each.key]
  network            = var.gateways[each.key].network
  project            = var.gateways[each.key].project != null ? var.gateways[each.key].project : var.project
  region             = var.gateways[each.key].region != null ? var.gateways[each.key].region : var.region
  stack_type         = var.gateways[each.key].stack_type
  dynamic "params" {
    for_each = var.gateways[each.key].params == null ? [] : [var.gateways[each.key].params]
    iterator = item_params
    content {
      resource_manager_tags = item_params.value.resource_manager_tags
    }
  }
  dynamic "timeouts" {
    for_each = var.gateways[each.key].timeouts == null ? [] : [var.gateways[each.key].timeouts]
    iterator = item_timeouts
    content {
      create = item_timeouts.value.create
      delete = item_timeouts.value.delete
      update = item_timeouts.value.update
    }
  }
  dynamic "vpn_interfaces" {
    for_each = var.gateways[each.key].vpn_interfaces
    iterator = item_vpn_interfaces
    content {
      id                      = item_vpn_interfaces.value.id
      interconnect_attachment = item_vpn_interfaces.value.interconnect_attachment
    }
  }
}
