output "router" {
  sensitive = true
  value = {
    id        = google_compute_router.this.id
    name      = google_compute_router.this.name
    self_link = google_compute_router.this.self_link
    project   = google_compute_router.this.project
    region    = google_compute_router.this.region
    network   = google_compute_router.this.network
    asn       = try(google_compute_router.this.bgp[0].asn, null)
  }
}
