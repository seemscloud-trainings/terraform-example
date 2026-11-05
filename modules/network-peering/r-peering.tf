resource "google_compute_network_peering" "this" {
  deletion_policy                     = var.peering.deletion_policy
  export_custom_routes                = var.peering.export_custom_routes
  export_subnet_routes_with_public_ip = var.peering.export_subnet_routes_with_public_ip
  import_custom_routes                = var.peering.import_custom_routes
  import_subnet_routes_with_public_ip = var.peering.import_subnet_routes_with_public_ip
  name                                = local.naming.peering
  network                             = var.peering.network
  peer_network                        = var.peering.peer_network
  stack_type                          = var.peering.stack_type
  update_strategy                     = var.peering.update_strategy
  dynamic "timeouts" {
    for_each = var.peering.timeouts == null ? [] : [
      var.peering.timeouts,

    ]
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
