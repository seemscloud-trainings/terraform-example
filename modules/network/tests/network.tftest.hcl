mock_provider "google" {}

variables {
  project = "test-project"
  network = {
    name         = "atlas"
    routing_mode = "GLOBAL"
  }
}

run "global_network" {
  command = apply
  assert {
    condition     = output.network.name == "atlas" && output.network.routing_mode == "GLOBAL"
    error_message = "Network must be created without any subnet or region input."
  }
}

run "invalid_name" {
  command = plan
  variables {
    network = {
      name = "INVALID_NAME"
    }
  }
  expect_failures = [
    var.network,
  ]
}
