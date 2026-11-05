resource "google_tags_tag_value" "this" {
  for_each        = var.values
  short_name      = local.naming.values[each.key]
  description     = each.value.description
  deletion_policy = each.value.deletion_policy
  parent          = each.value.key != null ? google_tags_tag_key.this[each.value.key].id : each.value.parent
  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
