mock_provider "google" {}
variables {
  project = "test-project"
  region  = "europe-west1"
}
run "empty" {
  command = apply
  assert {
    condition     = length(output.routers) == 0 && length(output.interfaces) == 0 && length(output.peers) == 0
    error_message = "Empty maps must create nothing."
  }
}
run "standalone_router" {
  command = apply
  variables {
    routers = {
      nat = {
        name    = "egress"
        network = "projects/test-project/global/networks/app"
      }
    }
  }
  assert {
    condition     = google_compute_router.this["nat"].name == "egress" && output.routers["nat"].asn == null && length(output.interfaces) == 0 && length(output.peers) == 0
    error_message = "Router must work without any VPN, interface or BGP peer."
  }
}
run "insert_router" {
  command = apply
  variables {
    routers = {
      core = {
        name    = "core"
        network = "projects/test-project/global/networks/app"
        bgp = {
          asn = 65001
        }
      }
      nat = {
        name    = "egress"
        network = "projects/test-project/global/networks/app"
      }
    }
  }
  assert {
    condition     = output.routers["nat"].id == run.standalone_router.routers["nat"].id
    error_message = "Adding another router must preserve the existing router ID."
  }
}
run "remove_other_router" {
  command = apply
  variables {
    routers = {
      nat = {
        name    = "egress"
        network = "projects/test-project/global/networks/app"
      }
    }
  }
  assert {
    condition     = length(output.routers) == 1 && output.routers["nat"].id == run.standalone_router.routers["nat"].id
    error_message = "Removing a different router must not change the surviving router ID."
  }
}
run "managed_interfaces_and_peers" {
  command = apply
  variables {
    routers = {
      core = {
        name    = "core"
        project = "host-project"
        region  = "europe-west4"
        network = "projects/host-project/global/networks/app"
        bgp = {
          asn            = 65001
          advertise_mode = "CUSTOM"
          advertised_ip_ranges = {
            app = {
              range = "10.10.0.0/16"
            }
          }
        }
      }
    }
    interfaces = {
      primary = {
        name       = "primary"
        router_key = "core"
        vpn_tunnel = "projects/host-project/regions/europe-west4/vpnTunnels/primary"
        ip_range   = "169.254.10.1/30"
      }
    }
    peers = {
      primary = {
        name                           = "primary"
        router_key                     = "core"
        interface_key                  = "primary"
        peer_asn                       = 65002
        peer_ip_address                = "169.254.10.2"
        enable                         = false
        advertised_route_priority      = 0
        zero_advertised_route_priority = true
      }
    }
  }
  assert {
    condition     = google_compute_router_interface.this["primary"].router == google_compute_router.this["core"].name && google_compute_router_peer.this["primary"].interface == google_compute_router_interface.this["primary"].name && output.peers["primary"].project == "host-project" && output.peers["primary"].region == "europe-west4" && output.routers["core"].asn == 65001
    error_message = "Managed references must inherit the correct router, project and region."
  }
  assert {
    condition     = !google_compute_router_peer.this["primary"].enable && google_compute_router_peer.this["primary"].advertised_route_priority == 0
    error_message = "False and zero must not be replaced with defaults."
  }
}
run "existing_router_interconnect" {
  command = apply
  variables {
    interfaces = {
      vlan = {
        name                    = "dedicated"
        router                  = "existing"
        interconnect_attachment = "projects/test-project/regions/europe-west1/interconnectAttachments/vlan"
        ip_range                = "169.254.20.1/30"
      }
    }
    peers = {
      vlan = {
        name            = "dedicated"
        router          = "existing"
        interface_key   = "vlan"
        peer_asn        = 65003
        peer_ip_address = "169.254.20.2"
        bfd = {
          session_initialization_mode = "ACTIVE"
          min_receive_interval        = 1000
          min_transmit_interval       = 1000
          multiplier                  = 5
        }
      }
    }
  }
  assert {
    condition     = length(output.routers) == 0 && output.interfaces["vlan"].router == "existing" && length(google_compute_router_peer.this["vlan"].bfd) == 1
    error_message = "Configuration-only mode must support an existing Interconnect router without creating another router."
  }
}
run "bad_router_key" {
  command = plan
  variables {
    interfaces = {
      bad = {
        name       = "invalid"
        router_key = "missing"
      }
    }
  }
  expect_failures = [var.interfaces]
}
run "missing_router_choice" {
  command = plan
  variables {
    interfaces = {
      bad = {
        name = "invalid"
      }
    }
  }
  expect_failures = [var.interfaces]
}

run "peer_interface_router_mismatch" {
  command = plan
  variables {
    interfaces = {
      primary = {
        name       = "existing"
        router     = "first"
        vpn_tunnel = "existing-tunnel"
      }
    }
    peers = {
      primary = {
        name          = "mismatch"
        router        = "second"
        interface_key = "primary"
        peer_asn      = 65002
      }
    }
  }
  expect_failures = [google_compute_router_peer.this]
}
