locals {
  tunnel_context = {
    for k, v in var.tunnels : k => {
      project = v.project != null ? v.project : (v.gateway_key != null ? google_compute_ha_vpn_gateway.this[v.gateway_key].project : var.project)
      region  = v.region != null ? v.region : (v.gateway_key != null ? google_compute_ha_vpn_gateway.this[v.gateway_key].region : var.region)
    }
  }
  secret_keys = {
    for k, v in var.tunnels : k => v.secret_key != null ? v.secret_key : k
  }
}
