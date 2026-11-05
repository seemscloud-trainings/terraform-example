resource "google_compute_subnetwork" "this" {
  for_each                         = var.subnetworks
  allow_subnet_cidr_routes_overlap = each.value.allow_subnet_cidr_routes_overlap
  deletion_policy                  = each.value.deletion_policy
  description                      = each.value.description
  external_ipv6_prefix             = each.value.external_ipv6_prefix
  internal_ipv6_prefix             = each.value.internal_ipv6_prefix
  ip_cidr_range                    = each.value.ip_cidr_range
  ip_collection                    = each.value.ip_collection
  ipv6_access_type                 = each.value.ipv6_access_type
  name                             = local.naming.subnetworks[each.key]
  network                          = each.value.network
  private_ip_google_access         = each.value.private_ip_google_access
  private_ipv6_google_access       = each.value.private_ipv6_google_access
  project                          = each.value.project != null ? each.value.project : var.project
  purpose                          = each.value.purpose
  region                           = each.value.region != null ? each.value.region : var.region
  reserved_internal_range          = each.value.reserved_internal_range
  resolve_subnet_mask              = each.value.resolve_subnet_mask
  role                             = each.value.role
  send_secondary_ip_range_if_empty = each.value.send_secondary_ip_range_if_empty
  stack_type                       = each.value.stack_type
  dynamic "log_config" {
    for_each = each.value.log_config == null ? [] : [
      each.value.log_config,
    ]
    iterator = item_log_config
    content {
      aggregation_interval = item_log_config.value.aggregation_interval
      filter_expr          = item_log_config.value.filter_expr
      flow_sampling        = item_log_config.value.flow_sampling
      metadata             = item_log_config.value.metadata
      metadata_fields      = item_log_config.value.metadata_fields
    }
  }
  dynamic "params" {
    for_each = each.value.params == null ? [] : [
      each.value.params,
    ]
    iterator = item_params
    content {
      resource_manager_tags = item_params.value.resource_manager_tags
    }
  }
  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_range
    iterator = item_secondary_ip_range
    content {
      ip_cidr_range           = item_secondary_ip_range.value.ip_cidr_range
      range_name              = item_secondary_ip_range.value.range_name
      reserved_internal_range = item_secondary_ip_range.value.reserved_internal_range
    }
  }
  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [
      each.value.timeouts,
    ]
    iterator = item_timeouts
    content {
      create = item_timeouts.value.create
      delete = item_timeouts.value.delete
      update = item_timeouts.value.update
    }
  }
}
