resource "google_compute_firewall" "this" {
  deletion_policy         = var.firewall.deletion_policy
  description             = var.firewall.description
  destination_ranges      = var.firewall.destination_ranges
  direction               = var.firewall.direction
  disabled                = var.firewall.disabled
  enable_logging          = var.firewall.enable_logging
  name                    = local.naming.firewall
  network                 = var.firewall.network
  priority                = var.firewall.priority
  project                 = var.firewall.project != null ? var.firewall.project : var.project
  source_ranges           = var.firewall.source_ranges
  source_service_accounts = var.firewall.source_service_accounts
  source_tags             = var.firewall.source_tags
  target_service_accounts = var.firewall.target_service_accounts
  target_tags             = var.firewall.target_tags
  dynamic "allow" {
    for_each = var.firewall.allow
    content {
      ports    = allow.value.ports
      protocol = allow.value.protocol
    }
  }
  dynamic "deny" {
    for_each = var.firewall.deny
    content {
      ports    = deny.value.ports
      protocol = deny.value.protocol
    }
  }
  dynamic "log_config" {
    for_each = var.firewall.log_config == null ? [] : [
      var.firewall.log_config,
    ]
    content {
      metadata = log_config.value.metadata
    }
  }
  dynamic "params" {
    for_each = var.firewall.params == null ? [] : [
      var.firewall.params,
    ]
    content {
      resource_manager_tags = params.value.resource_manager_tags
    }
  }
  dynamic "timeouts" {
    for_each = var.firewall.timeouts == null ? [] : [
      var.firewall.timeouts,
    ]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      update = timeouts.value.update
    }
  }
}
