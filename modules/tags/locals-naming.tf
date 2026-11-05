locals {
  naming = {
    keys = {
      for k, v in var.keys : k => v.short_name
    }
    values = {
      for k, v in var.values : k => v.short_name
    }
  }
}
