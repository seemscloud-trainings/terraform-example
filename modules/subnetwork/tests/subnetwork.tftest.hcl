mock_provider "google" {}

variables {
  project = "test-project"
  region  = "europe-west1"
  subnetworks = {
    main = {
      name          = "atlas"
      network       = "projects/test-project/global/networks/atlas"
      ip_cidr_range = "10.80.0.0/24"
    }
  }
}

run "existing_network" {
  command = apply
  assert {
    condition     = output.subnetworks["main"].network == "projects/test-project/global/networks/atlas" && output.subnetworks["main"].region == "europe-west1"
    error_message = "Subnet must use the supplied existing network and region."
  }
}

run "stable_keys" {
  command = apply
  variables {
    subnetworks = {
      added = {
        name          = "orion"
        network       = "projects/test-project/global/networks/atlas"
        ip_cidr_range = "10.81.0.0/24"
      }
      main = {
        name          = "atlas"
        network       = "projects/test-project/global/networks/atlas"
        ip_cidr_range = "10.80.0.0/24"
      }
    }
  }
  assert {
    condition     = output.subnetworks["main"].id == run.existing_network.subnetworks["main"].id
    error_message = "Adding a subnet must preserve existing identity."
  }
}

run "invalid_cidr" {
  command = plan
  variables {
    subnetworks = {
      main = {
        name          = "atlas"
        network       = "projects/test-project/global/networks/atlas"
        ip_cidr_range = "invalid"
      }
    }
  }
  expect_failures = [var.subnetworks]
}
