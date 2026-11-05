mock_provider "google" {}

variables {
  project = "test-project"
  zone    = "europe-west1-b"
  instance = {
    name         = "atlas"
    machine_type = "e2-micro"
    boot_disk = {
      initialize_params = {
        image = "debian-cloud/debian-12"
        size  = 10
      }
    }
    network_interface = [

      {
        subnetwork = "projects/test-project/regions/europe-west1/subnetworks/atlas"
      }
      ,
    ]
  }
}

run "private_instance" {
  command = apply
  assert {
    condition     = output.instance.name == "atlas" && length(google_compute_instance.this.network_interface[0].access_config) == 0 && length(google_compute_instance.this.network_interface) == 1
    error_message = "One private VM must be created without implicit public access."
  }
}

run "public_and_optional_features" {
  command = plan
  variables {
    instance = {
      name         = "orion"
      machine_type = "e2-micro"
      zone         = "us-east1-b"
      labels = {
        environment = "test"
      }
      metadata = {
        enable-oslogin = "TRUE"
      }
      boot_disk = {
        initialize_params = {
          image = "debian-cloud/debian-12"
          type  = "pd-balanced"
          size  = 20
        }
      }
      network_interface = [

        {
          subnetwork = "projects/test-project/regions/us-east1/subnetworks/orion"
          access_config = {
            public = {
              network_tier = "PREMIUM"
            }
          }
        }
        ,
      ]
      scheduling = {
        provisioning_model  = "SPOT"
        automatic_restart   = false
        on_host_maintenance = "TERMINATE"
      }
      shielded_instance_config = {
        enable_secure_boot = true
        enable_vtpm        = true
      }
      service_account = {
        email = "example@test-project.iam.gserviceaccount.com"
        scopes = [
          "cloud-platform",
        ]
      }
    }
  }
  assert {
    condition     = output.instance.zone == "us-east1-b" && length(google_compute_instance.this.network_interface[0].access_config) == 1 && google_compute_instance.this.scheduling[0].provisioning_model == "SPOT" && google_compute_instance.this.shielded_instance_config[0].enable_secure_boot
    error_message = "Zone override, public access and optional configuration must reach the provider."
  }
}

run "missing_nic" {
  command = plan
  variables {
    instance = {
      name         = "atlas"
      machine_type = "e2-micro"
      boot_disk = {
        source = "existing-disk"
      }
      network_interface = []
    }
  }
  expect_failures = [
    var.instance,
  ]
}

run "conflicting_boot_disk" {
  command = plan
  variables {
    instance = {
      name         = "atlas"
      machine_type = "e2-micro"
      boot_disk = {
        source = "existing-disk"
        initialize_params = {
          image = "debian-cloud/debian-12"
        }
      }
      network_interface = [

        {
          subnetwork = "existing-subnet"
        }
        ,
      ]
    }
  }
  expect_failures = [
    var.instance,
  ]
}
