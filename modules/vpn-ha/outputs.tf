output "gateway" {
  sensitive = true
  value = {
    id             = google_compute_ha_vpn_gateway.this.id
    name           = google_compute_ha_vpn_gateway.this.name
    self_link      = google_compute_ha_vpn_gateway.this.self_link
    network        = google_compute_ha_vpn_gateway.this.network
    project        = google_compute_ha_vpn_gateway.this.project
    region         = google_compute_ha_vpn_gateway.this.region
    vpn_interfaces = google_compute_ha_vpn_gateway.this.vpn_interfaces
  }
}
