locals {
  naming = {
    tunnels = {
      for k, v in var.tunnels : k => v.name
    }
  }
}
