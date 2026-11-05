mock_provider "google" {}

variables {
  project = "test-project"
  hub = {
    name            = "nexus"
    preset_topology = "MESH"
    policy_mode     = "PRESET"
  }
}

run "atomic_hub" {
  command = plan
  assert {
    condition     = google_network_connectivity_hub.this.name == "nexus" && google_network_connectivity_hub.this.preset_topology == "MESH"
    error_message = "One hub with the requested topology must be created."
  }
}
