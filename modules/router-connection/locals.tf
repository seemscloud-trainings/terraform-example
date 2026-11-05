locals {
  interfaces_context = {
    for k, v in var.interfaces : k => {
      router  = var.router
      project = v.project != null ? v.project : var.project
      region  = v.region != null ? v.region : var.region
    }
  }
  peers_context = {
    for k, v in var.peers : k => {
      router  = var.router
      project = v.project != null ? v.project : var.project
      region  = v.region != null ? v.region : var.region
    }
  }
}
