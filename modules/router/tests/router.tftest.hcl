mock_provider "google" {}

variables {
  project = "test-project"
  region  = "europe-west1"
  router = {
    name    = "atlas"
    network = "projects/test-project/global/networks/atlas"
  }
}

run "single_resource" {
  command = apply
  assert {
    condition     = output.router.name == "atlas" && output.router.self_link == google_compute_router.this.self_link
    error_message = "The module must export one resource object."
  }
}

run "metadata_update_preserves_identity" {
  command = apply
  variables {
    router = {
      name        = "atlas"
      network     = "projects/test-project/global/networks/atlas"
      description = "updated description"
    }
  }
  assert {
    condition     = output.router.id == run.single_resource.router.id
    error_message = "A metadata update must preserve resource identity."
  }
}

run "invalid_name" {
  command = plan
  variables {
    router = {
      name    = "INVALID_NAME"
      network = "projects/test-project/global/networks/atlas"
    }
  }
  expect_failures = [var.router]
}

run "bgp_and_context" {
  command = plan
  variables {
    router = {
      name    = "atlas"
      network = "projects/host/global/networks/atlas"
      project = "host"
      region  = "us-east1"
      bgp = {
        asn            = 65001
        advertise_mode = "CUSTOM"
        advertised_ip_ranges = {
          primary = {
            range = "10.80.0.0/24"
          }
        }
      }
      md5_authentication_keys = {
        name = "primary"
        key  = "mock-only"
      }
    }
  }
  assert {
    condition     = output.router.asn == 65001 && output.router.project == "host" && output.router.region == "us-east1" && length(google_compute_router.this.bgp[0].advertised_ip_ranges) == 1
    error_message = "Atomic router must retain BGP blocks and explicit context overrides."
  }
}
