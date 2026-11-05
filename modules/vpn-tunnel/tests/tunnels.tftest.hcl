mock_provider "google" {}

variables {
  write_only_shared_secrets = {}
  project                   = "project-a"
  region                    = "europe-west1"
}

run "ha_pair" {
  command = apply
  variables {
    shared_secrets = {
      primary   = "mock-primary-secret"
      secondary = "mock-secondary-secret"
    }
    tunnels = {
      a_primary = {
        name                  = "to-orion-primary"
        vpn_gateway           = "projects/project-a/regions/europe-west1/vpnGateways/a"
        peer_gcp_gateway      = "projects/project-b/regions/europe-west1/vpnGateways/b"
        vpn_gateway_interface = 0
        router                = "projects/project-a/regions/europe-west1/routers/atlas"
        secret_key            = "primary"
      }
      a_secondary = {
        name                  = "to-orion-secondary"
        vpn_gateway           = "projects/project-a/regions/europe-west1/vpnGateways/a"
        peer_gcp_gateway      = "projects/project-b/regions/europe-west1/vpnGateways/b"
        vpn_gateway_interface = 1
        router                = "projects/project-a/regions/europe-west1/routers/atlas"
        secret_key            = "secondary"
      }
      b_primary = {
        name                  = "to-atlas-primary"
        vpn_gateway           = "projects/project-b/regions/europe-west1/vpnGateways/b"
        peer_gcp_gateway      = "projects/project-a/regions/europe-west1/vpnGateways/a"
        vpn_gateway_interface = 0
        router                = "projects/project-b/regions/europe-west1/routers/orion"
        secret_key            = "primary"
      }
      b_secondary = {
        name                  = "to-atlas-secondary"
        vpn_gateway           = "projects/project-b/regions/europe-west1/vpnGateways/b"
        peer_gcp_gateway      = "projects/project-a/regions/europe-west1/vpnGateways/a"
        vpn_gateway_interface = 1
        router                = "projects/project-b/regions/europe-west1/routers/orion"
        secret_key            = "secondary"
      }
    }
  }
  assert {
    condition     = length(output.tunnels) == 4 && output.tunnels["a_primary"].vpn_gateway_interface == 0
    error_message = "The module must create four endpoints from existing gateways."
  }
}

run "existing_gateway_external_peer" {
  command = apply
  variables {
    shared_secrets = {
      external = "mock-external-secret"
    }
    tunnels = {
      external = {
        name                            = "external"
        vpn_gateway                     = "projects/project-a/regions/europe-west1/vpnGateways/existing"
        vpn_gateway_interface           = 0
        peer_external_gateway           = "projects/project-a/global/externalVpnGateways/onprem"
        peer_external_gateway_interface = 0
        router                          = "existing"
      }
    }
  }
  assert {
    condition     = google_compute_vpn_tunnel.this["external"].peer_external_gateway_interface == 0
    error_message = "An existing HA gateway and external peer must not require new gateway resources."
  }
}

run "write_only_secret" {
  command = apply
  variables {
    write_only_shared_secrets = {
      tunnel = "mock-ephemeral-secret"
    }
    tunnels = {
      tunnel = {
        name                     = "write-only"
        vpn_gateway              = "projects/project-a/regions/europe-west1/vpnGateways/existing"
        vpn_gateway_interface    = 0
        peer_gcp_gateway         = "projects/project-b/regions/europe-west1/vpnGateways/existing"
        router                   = "existing"
        secret_mode              = "write_only"
        shared_secret_wo_version = "1"
      }
    }
  }
  assert {
    condition     = google_compute_vpn_tunnel.this["tunnel"].shared_secret_wo_version == "1"
    error_message = "Write-only rotation version must be preserved."
  }
}

run "missing_psk" {
  command = plan
  variables {
    tunnels = {
      missing = {
        name                  = "missing"
        vpn_gateway           = "projects/project-a/regions/europe-west1/vpnGateways/existing"
        vpn_gateway_interface = 0
        peer_gcp_gateway      = "projects/project-b/regions/europe-west1/vpnGateways/existing"
        router                = "existing"
      }
    }
  }
  expect_failures = [
    var.tunnels,
  ]
}

run "invalid_ha_interface" {
  command = plan
  variables {
    shared_secrets = {
      invalid = "mock-secret"
    }
    tunnels = {
      invalid = {
        name                  = "invalid"
        vpn_gateway           = "projects/project-a/regions/europe-west1/vpnGateways/existing"
        vpn_gateway_interface = 2
        peer_gcp_gateway      = "projects/project-b/regions/europe-west1/vpnGateways/existing"
        router                = "existing"
      }
    }
  }
  expect_failures = [
    var.tunnels,
  ]
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
        router                   = "existing"
        secret_mode              = "write_only"
        shared_secret_wo_version = "1"
      }
    }
  }
  expect_failures = [
    var.write_only_shared_secrets,
  ]
}

