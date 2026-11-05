output "gateways" {
  sensitive   = true
  description = "Keyed resource identifiers/settings; no authentication secrets are exported."
  value = { for k, v in google_compute_ha_vpn_gateway.this : k => {
    id             = v.id
    name           = v.name
    self_link      = v.self_link
    network        = v.network
    project        = v.project
    region         = v.region
    vpn_interfaces = v.vpn_interfaces
  } }
}
output "tunnels" {
  sensitive   = true
  description = "Keyed resource identifiers/settings; no authentication secrets are exported."
  value = { for k, v in google_compute_vpn_tunnel.this : k => {
    id                    = v.id
    name                  = v.name
    self_link             = v.self_link
    project               = v.project
    region                = v.region
    router                = v.router
    vpn_gateway           = v.vpn_gateway
    vpn_gateway_interface = v.vpn_gateway_interface
    peer_gcp_gateway      = v.peer_gcp_gateway
    peer_external_gateway = v.peer_external_gateway
    detailed_status       = v.detailed_status
  } }
}
