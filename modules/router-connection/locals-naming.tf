locals {
  naming = {
    interfaces = {
      for k, v in var.interfaces : k => v.name
    }
    peers = {
      for k, v in var.peers : k => v.name
    }
  }
}
