resource "google_tags_tag_key" "this" {
  for_each             = var.keys
  short_name           = local.naming.keys[each.key]
  parent               = each.value.parent
  description          = each.value.description
  deletion_policy      = each.value.deletion_policy
  allowed_values_regex = each.value.allowed_values_regex
  purpose              = each.value.purpose
  purpose_data         = each.value.purpose_data
  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
