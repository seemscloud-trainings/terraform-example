output "routers" {
  sensitive   = true
  description = "Keyed resource identifiers/settings; no authentication secrets are exported."
  value = {
    for k, v in google_compute_router.this : k => {
      id        = v.id
      name      = v.name
      self_link = v.self_link
      project   = v.project
      region    = v.region
      network   = v.network
    }
  }
}
output "interfaces" {
  sensitive   = true
  description = "Keyed resource identifiers/settings; no authentication secrets are exported."
  value = {
    for k, v in google_compute_router_interface.this : k => {
      id                      = v.id
      name                    = v.name
      router                  = v.router
      vpn_tunnel              = v.vpn_tunnel
      interconnect_attachment = v.interconnect_attachment
      project                 = v.project
      region                  = v.region
      ip_range                = v.ip_range
      ip_version              = v.ip_version
    }
  }
}
output "peers" {
  sensitive   = true
  description = "Keyed resource identifiers/settings; no authentication secrets are exported."
  value = {
    for k, v in google_compute_router_peer.this : k => {
      id              = v.id
      name            = v.name
      router          = v.router
      project         = v.project
      region          = v.region
      interface       = v.interface
      peer_asn        = v.peer_asn
      peer_ip_address = v.peer_ip_address
    }
  }
}
