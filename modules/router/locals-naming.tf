locals {
  naming = {
    routers = {
      for k, v in var.routers : k => v.name
    }
    interfaces = {
      for k, v in var.interfaces : k => v.name
    }
    peers = {
      for k, v in var.peers : k => v.name
    }
  }
}
