output "peering" {
  value = {
    id            = google_compute_network_peering.this.id
    name          = google_compute_network_peering.this.name
    network       = google_compute_network_peering.this.network
    peer_network  = google_compute_network_peering.this.peer_network
    state         = google_compute_network_peering.this.state
    state_details = google_compute_network_peering.this.state_details
  }
}
