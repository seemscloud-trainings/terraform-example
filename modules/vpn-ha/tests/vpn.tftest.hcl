mock_provider "google" {}
variables {
  write_only_shared_secrets = {}
  project                   = "project-a"
  region                    = "europe-west1"
}
run "gateways_only" {
  command = apply
  variables {
    gateways = {
      a = { name = "gateway-a", network = "projects/project-a/global/networks/a" }
      b = { name = "gateway-b", project = "project-b", network = "projects/project-b/global/networks/b" }
    }
  }
  assert {
    condition     = length(output.gateways) == 2 && length(output.tunnels) == 0 && output.gateways["b"].project == "project-b"
    error_message = "Gateways must be independently creatable across projects without routers or tunnels."
  }
}
run "ha_pair" {
  command = apply
  variables {
    gateways = {
      a = { name = "gateway-a", network = "projects/project-a/global/networks/a" }
      b = { name = "gateway-b", project = "project-b", network = "projects/project-b/global/networks/b" }
    }
    shared_secrets = { primary = "mock-primary-secret", secondary = "mock-secondary-secret" }
    tunnels = {
      a_primary   = { name = "a-primary", gateway_key = "a", peer_gateway_key = "b", vpn_gateway_interface = 0, router = "projects/project-a/regions/europe-west1/routers/router-a", secret_key = "primary" }
      a_secondary = { name = "a-secondary", gateway_key = "a", peer_gateway_key = "b", vpn_gateway_interface = 1, router = "projects/project-a/regions/europe-west1/routers/router-a", secret_key = "secondary" }
      b_primary   = { name = "b-primary", gateway_key = "b", peer_gateway_key = "a", vpn_gateway_interface = 0, router = "projects/project-b/regions/europe-west1/routers/router-b", secret_key = "primary" }
      b_secondary = { name = "b-secondary", gateway_key = "b", peer_gateway_key = "a", vpn_gateway_interface = 1, router = "projects/project-b/regions/europe-west1/routers/router-b", secret_key = "secondary" }
    }
  }
  assert {
    condition     = length(output.tunnels) == 4 && output.gateways["a"].id == run.gateways_only.gateways["a"].id && output.gateways["b"].id == run.gateways_only.gateways["b"].id
    error_message = "Four tunnel endpoints must preserve both previously created gateways."
  }
  assert {
    condition     = google_compute_vpn_tunnel.this["a_primary"].peer_gcp_gateway == google_compute_ha_vpn_gateway.this["b"].self_link && google_compute_vpn_tunnel.this["b_primary"].project == "project-b" && google_compute_vpn_tunnel.this["a_secondary"].vpn_gateway_interface == 1
    error_message = "HA tunnel endpoints must reference the correct peer, project and interface."
  }
  assert {
    condition     = google_compute_vpn_tunnel.this["a_primary"].shared_secret == google_compute_vpn_tunnel.this["b_primary"].shared_secret
    error_message = "Reciprocal endpoints must receive the same PSK."
  }
}
run "existing_gateway_external_peer" {
  command = apply
  variables {
    shared_secrets = { external = "mock-external-secret" }
    tunnels        = { external = { name = "external", vpn_gateway = "projects/project-a/regions/europe-west1/vpnGateways/existing", vpn_gateway_interface = 0, peer_external_gateway = "projects/project-a/global/externalVpnGateways/onprem", peer_external_gateway_interface = 0, router = "existing-router" } }
  }
  assert {
    condition     = length(output.gateways) == 0 && google_compute_vpn_tunnel.this["external"].peer_external_gateway_interface == 0
    error_message = "An existing HA gateway and external peer must not require new gateway resources."
  }
}
run "write_only_secret" {
  command = apply
  variables {
    write_only_shared_secrets = { tunnel = "mock-ephemeral-secret" }
    tunnels                   = { tunnel = { name = "write-only", vpn_gateway = "projects/project-a/regions/europe-west1/vpnGateways/existing", vpn_gateway_interface = 0, peer_gcp_gateway = "projects/project-b/regions/europe-west1/vpnGateways/existing", router = "existing-router", secret_mode = "write_only", shared_secret_wo_version = "1" } }
  }
  assert {
    condition     = google_compute_vpn_tunnel.this["tunnel"].shared_secret_wo_version == "1"
    error_message = "Write-only rotation version must be preserved."
  }
}
run "missing_psk" {
  command = plan
  variables { tunnels = { missing = { name = "missing", vpn_gateway = "projects/project-a/regions/europe-west1/vpnGateways/existing", vpn_gateway_interface = 0, peer_gcp_gateway = "projects/project-b/regions/europe-west1/vpnGateways/existing", router = "existing-router" } } }
  expect_failures = [var.tunnels]
}
run "invalid_ha_interface" {
  command = plan
  variables {
    shared_secrets = { invalid = "mock-secret" }
    tunnels        = { invalid = { name = "invalid", vpn_gateway = "projects/project-a/regions/europe-west1/vpnGateways/existing", vpn_gateway_interface = 2, peer_gcp_gateway = "projects/project-b/regions/europe-west1/vpnGateways/existing", router = "existing-router" } }
  }
  expect_failures = [var.tunnels]
}

run "missing_write_only_psk" {
  command = plan
  variables {
    tunnels = {
      missing = {
        name                     = "missing-write-only"
        vpn_gateway              = "projects/project-a/regions/europe-west1/vpnGateways/existing"
        vpn_gateway_interface    = 0
        peer_gcp_gateway         = "projects/project-b/regions/europe-west1/vpnGateways/existing"
        router                   = "existing-router"
        secret_mode              = "write_only"
        shared_secret_wo_version = "1"
      }
    }
  }
  expect_failures = [var.write_only_shared_secrets]
}

run "interconnect_gateway_interfaces" {
  command = apply
  variables {
    gateways = {
      interconnect = {
        name    = "interconnect-ha"
        network = "projects/project-a/global/networks/interconnect"
        vpn_interfaces = {
          primary   = { id = 0, interconnect_attachment = "projects/project-a/regions/europe-west1/interconnectAttachments/primary" }
          secondary = { id = 1, interconnect_attachment = "projects/project-a/regions/europe-west1/interconnectAttachments/secondary" }
        }
      }
    }
  }
  assert {
    condition     = toset([for v in google_compute_ha_vpn_gateway.this["interconnect"].vpn_interfaces : v.id]) == toset([0, 1])
    error_message = "Configurable nested HA interface IDs must be preserved."
  }
}
