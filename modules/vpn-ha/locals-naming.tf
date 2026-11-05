locals {
  naming = {
    gateways = {
      for k, v in var.gateways : k => v.name
    }
    tunnels = {
      for k, v in var.tunnels : k => v.name
    }
  }
}
