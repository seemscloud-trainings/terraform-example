output "hub" {
  value = {
    id        = google_network_connectivity_hub.this.id
    name      = google_network_connectivity_hub.this.name
    project   = google_network_connectivity_hub.this.project
    state     = google_network_connectivity_hub.this.state
    unique_id = google_network_connectivity_hub.this.unique_id
  }
}
