resource "google_compute_ha_vpn_gateway" "this" {
  deletion_policy    = var.gateway.deletion_policy
  description        = var.gateway.description
  gateway_ip_version = var.gateway.gateway_ip_version
  labels             = var.gateway.labels
  name               = local.naming.gateway
  network            = var.gateway.network
  project            = var.gateway.project != null ? var.gateway.project : var.project
  region             = var.gateway.region != null ? var.gateway.region : var.region
  stack_type         = var.gateway.stack_type
  dynamic "params" {
    for_each = var.gateway.params == null ? [] : [var.gateway.params]
    iterator = item_params
    content {
      resource_manager_tags = item_params.value.resource_manager_tags
    }
  }
  dynamic "timeouts" {
    for_each = var.gateway.timeouts == null ? [] : [var.gateway.timeouts]
    iterator = item_timeouts
    content {
      create = item_timeouts.value.create
      delete = item_timeouts.value.delete
      update = item_timeouts.value.update
    }
  }
  dynamic "vpn_interfaces" {
    for_each = var.gateway.vpn_interfaces
    iterator = item_vpn_interfaces
    content {
      id                      = item_vpn_interfaces.value.id
      interconnect_attachment = item_vpn_interfaces.value.interconnect_attachment
    }
  }
}
