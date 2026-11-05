mock_provider "google" {}

variables {
  project = "test-project"
  peering = {
    name                 = "to-nebula"
    network              = "projects/test-project/global/networks/aurora"
    peer_network         = "projects/test-project/global/networks/nebula"
    import_custom_routes = false
    export_custom_routes = false
  }
}

run "directional_peering" {
  command = plan
  assert {
    condition     = google_compute_network_peering.this.network == var.peering.network && google_compute_network_peering.this.peer_network == var.peering.peer_network && !google_compute_network_peering.this.import_custom_routes
    error_message = "Peering must keep the supplied endpoints and route options."
  }
}

run "reject_same_network" {
  command = plan
  variables {
    peering = {
      name         = "loop"
      network      = "same-network"
      peer_network = "same-network"
    }
  }
  expect_failures = [
    var.peering,
  ]
}
