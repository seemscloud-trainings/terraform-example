output "network" {
  description = "Created VPC identifiers and effective settings."
  value = {
    id           = google_compute_network.this.id
    name         = google_compute_network.this.name
    self_link    = google_compute_network.this.self_link
    project      = google_compute_network.this.project
    network_id   = google_compute_network.this.network_id
    routing_mode = google_compute_network.this.routing_mode
    mtu          = google_compute_network.this.mtu
  }
}

