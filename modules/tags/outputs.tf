output "keys" {
  value = {
    for k, v in google_tags_tag_key.this : k => v.id
  }
}

output "values" {
  value = {
    for k, v in google_tags_tag_value.this : k => v.id
  }
}
