mock_provider "google" {}

variables {
  project = "test-project"
  region  = "europe-west1"
  gateway = {
    name    = "atlas"
    network = "projects/test-project/global/networks/atlas"
  }
}

run "single_resource" {
  command = apply
  assert {
    condition     = output.gateway.name == "atlas" && output.gateway.self_link == google_compute_ha_vpn_gateway.this.self_link
    error_message = "The module must export one resource object."
  }
}

run "metadata_update_preserves_identity" {
  command = apply
  variables {
    gateway = {
      name        = "atlas"
      network     = "projects/test-project/global/networks/atlas"
      description = "updated description"
    }
  }
  assert {
    condition     = output.gateway.id == run.single_resource.gateway.id
    error_message = "A metadata update must preserve resource identity."
  }
}

run "invalid_name" {
  command = plan
  variables {
    gateway = {
      name    = "INVALID_NAME"
      network = "projects/test-project/global/networks/atlas"
    }
  }
  expect_failures = [
    var.gateway,
  ]
}

run "interconnect_and_labels" {
  command = plan
  variables {
    gateway = {
      name    = "atlas"
      network = "projects/host/global/networks/atlas"
      project = "host"
      region  = "us-east1"
      labels = {
        environment = "test"
      }
      vpn_interfaces = {
        primary = {
          id                      = 0
          interconnect_attachment = "projects/host/regions/us-east1/interconnectAttachments/primary"
        }
        secondary = {
          id                      = 1
          interconnect_attachment = "projects/host/regions/us-east1/interconnectAttachments/secondary"
        }
      }
    }
  }
  assert {
    condition     = output.gateway.project == "host" && output.gateway.region == "us-east1" && length(google_compute_ha_vpn_gateway.this.vpn_interfaces) == 2 && google_compute_ha_vpn_gateway.this.labels["environment"] == "test"
    error_message = "Atomic gateway must retain interface IDs, labels and context overrides."
  }
}
