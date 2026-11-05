output "firewall" {
  value = {
    id        = google_compute_firewall.this.id
    name      = google_compute_firewall.this.name
    self_link = google_compute_firewall.this.self_link
    network   = google_compute_firewall.this.network
    project   = google_compute_firewall.this.project
  }
}
