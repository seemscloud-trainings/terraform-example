resource "google_compute_network" "this" {
  auto_create_subnetworks                   = var.network.auto_create_subnetworks
  bgp_always_compare_med                    = var.network.bgp_always_compare_med
  bgp_best_path_selection_mode              = var.network.bgp_best_path_selection_mode
  bgp_inter_region_cost                     = var.network.bgp_inter_region_cost
  delete_bgp_always_compare_med             = var.network.delete_bgp_always_compare_med
  delete_default_routes_on_create           = var.network.delete_default_routes_on_create
  deletion_policy                           = var.network.deletion_policy
  description                               = var.network.description
  enable_ula_internal_ipv6                  = var.network.enable_ula_internal_ipv6
  internal_ipv6_range                       = var.network.internal_ipv6_range
  mtu                                       = var.network.mtu
  name                                      = local.naming.network
  network_firewall_policy_enforcement_order = var.network.network_firewall_policy_enforcement_order
  network_profile                           = var.network.network_profile
  project                                   = local.network_project
  routing_mode                              = var.network.routing_mode
  dynamic "params" {
    for_each = var.network.params == null ? [] : [var.network.params]
    iterator = item_params
    content {
      resource_manager_tags = item_params.value.resource_manager_tags
    }
  }
  dynamic "timeouts" {
    for_each = var.network.timeouts == null ? [] : [var.network.timeouts]
    iterator = item_timeouts
    content {
      create = item_timeouts.value.create
      delete = item_timeouts.value.delete
      update = item_timeouts.value.update
    }
  }
}
