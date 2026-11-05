output "spoke" {
  value = {
    id        = google_network_connectivity_spoke.this.id
    name      = google_network_connectivity_spoke.this.name
    project   = google_network_connectivity_spoke.this.project
    state     = google_network_connectivity_spoke.this.state
    location  = google_network_connectivity_spoke.this.location
    unique_id = google_network_connectivity_spoke.this.unique_id
  }
}
