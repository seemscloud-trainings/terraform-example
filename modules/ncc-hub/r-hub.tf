resource "google_network_connectivity_hub" "this" {
  deletion_policy = var.hub.deletion_policy
  description     = var.hub.description
  export_psc      = var.hub.export_psc
  labels          = var.hub.labels
  name            = local.naming.hub
  policy_mode     = var.hub.policy_mode
  preset_topology = var.hub.preset_topology
  project         = var.hub.project != null ? var.hub.project : var.project
  dynamic "timeouts" {
    for_each = var.hub.timeouts == null ? [] : [
      var.hub.timeouts,
    ]
    iterator = item_timeouts
    content {
      create = item_timeouts.value.create
      delete = item_timeouts.value.delete
      update = item_timeouts.value.update
    }
  }
}
