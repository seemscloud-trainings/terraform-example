locals {
  network_project = var.network.project != null ? var.network.project : var.provider_config.project
}
