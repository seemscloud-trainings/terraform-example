mock_provider "google" {}

variables {
  project = "test-project"
  region  = "europe-west1"
  router  = "atlas"
  interfaces = {
    primary = {
      name       = "primary"
      vpn_tunnel = "projects/test-project/regions/europe-west1/vpnTunnels/primary"
      ip_range   = "169.254.10.1/30"
    }
  }
  peers = {
    primary = {
      name            = "primary"
      interface_key   = "primary"
      peer_asn        = 65002
      peer_ip_address = "169.254.10.2"
    }
  }
}

run "bind_existing_router" {
  command = apply
  assert {
    condition     = output.interfaces["primary"].router == "atlas" && output.peers["primary"].router == "atlas" && output.peers["primary"].interface == output.interfaces["primary"].name
    error_message = "Interfaces and peers must belong to the one supplied router."
  }
}

run "bad_interface" {
  command = plan
  variables {
    peers = {
      primary = {
        name          = "primary"
        interface_key = "missing"
        peer_asn      = 65002
      }
    }
  }
  expect_failures = [
    var.peers,
  ]
}
