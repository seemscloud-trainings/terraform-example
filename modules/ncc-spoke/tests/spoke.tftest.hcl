mock_provider "google" {}

variables {
  project = "test-project"
  spoke = {
    name     = "lyra"
    location = "global"
    hub      = "projects/test-project/locations/global/hubs/nexus"
    linked_vpc_network = {
      uri                   = "projects/test-project/global/networks/lyra"
      include_export_ranges = ["10.92.0.0/24"]
    }
  }
}

run "only_selected_subnet" {
  command = plan
  assert {
    condition     = google_network_connectivity_spoke.this.linked_vpc_network[0].include_export_ranges == tolist(["10.92.0.0/24"])
    error_message = "Only the explicitly selected subnet range may be exported."
  }
}

run "vpc_is_global" {
  command = plan
  variables {
    spoke = {
      name     = "lyra"
      location = "europe-west1"
      hub      = "projects/test-project/locations/global/hubs/nexus"
      linked_vpc_network = {
        uri = "projects/test-project/global/networks/lyra"
      }
    }
  }
  expect_failures = [var.spoke]
}

run "reject_two_attachment_types" {
  command = plan
  variables {
    spoke = {
      name     = "lyra"
      location = "global"
      hub      = "projects/test-project/locations/global/hubs/nexus"
      linked_vpc_network = {
        uri = "projects/test-project/global/networks/lyra"
      }
      linked_vpn_tunnels = {
        uris                       = ["existing-tunnel"]
        site_to_site_data_transfer = false
      }
    }
  }
  expect_failures = [var.spoke]
}
