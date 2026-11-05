locals {
  tunnel_context = {
    for k, v in var.tunnels : k => {
      project = v.project != null ? v.project : var.project
      region  = v.region != null ? v.region : var.region
    }
  }
  secret_keys = {
    for k, v in var.tunnels : k => v.secret_key != null ? v.secret_key : k
  }
}
