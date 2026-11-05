mock_provider "google" {
  mock_resource "google_compute_network" {
    defaults = {
      self_link = "https://www.googleapis.com/compute/v1/projects/unit-project/global/networks/unit-vpc"
    }
  }
}

variables {
  project = "unit-project"
  region  = "europe-west1"
  network = {
    name = "unit-vpc"
  }
}

run "network_without_subnets" {
  command = apply
  assert {
    condition     = length(output.subnetworks) == 0 && output.network.name == "unit-vpc" && !google_compute_network.this.auto_create_subnetworks
    error_message = "Default custom VPC must preserve the supplied name and create no implicit subnet resources."
  }
}

run "named_subnets" {
  command = apply
  variables {
    subnetworks = {
      application = {
        name          = "application-subnet"
        ip_cidr_range = "10.10.1.0/24"
      }
      database = {
        name          = "database-subnet"
        ip_cidr_range = "10.10.2.0/24"
        region        = "europe-west4"
      }
    }
  }
  assert {
    condition     = google_compute_subnetwork.this["application"].network == google_compute_network.this.self_link && google_compute_subnetwork.this["application"].project == "unit-project"
    error_message = "Subnet must default to the created network and effective project."
  }
  assert {
    condition     = output.subnetworks["application"].name == "application-subnet" && output.subnetworks["application"].region == "europe-west1" && output.subnetworks["database"].region == "europe-west4"
    error_message = "User names and regional overrides must be preserved."
  }
}

run "insert_between_existing_keys" {
  command = apply
  variables {
    subnetworks = {
      database = {
        name          = "database-subnet"
        ip_cidr_range = "10.10.2.0/24"
        region        = "europe-west4"
      }
      batch = {
        name          = "batch-subnet"
        ip_cidr_range = "10.10.3.0/24"
      }
      application = {
        name          = "application-subnet"
        ip_cidr_range = "10.10.1.0/24"
      }
    }
  }
  assert {
    condition     = length(output.subnetworks) == 3 && output.subnetworks["application"].id == run.named_subnets.subnetworks["application"].id && output.subnetworks["database"].id == run.named_subnets.subnetworks["database"].id
    error_message = "Insertion and map order must not recreate existing subnet identities."
  }
}

run "remove_only_batch" {
  command = apply
  variables {
    subnetworks = {
      application = {
        name          = "application-subnet"
        ip_cidr_range = "10.10.1.0/24"
      }
      database = {
        name          = "database-subnet"
        ip_cidr_range = "10.10.2.0/24"
        region        = "europe-west4"
      }
    }
  }
  assert {
    condition     = length(output.subnetworks) == 2 && output.subnetworks["application"].id == run.named_subnets.subnetworks["application"].id && output.subnetworks["database"].id == run.named_subnets.subnetworks["database"].id
    error_message = "Removing batch must preserve application and database."
  }
}

run "advanced_fields_and_secondary_maps" {
  command = apply
  variables {
    network = {
      name                            = "unit-vpc"
      routing_mode                    = "GLOBAL"
      mtu                             = 1500
      bgp_best_path_selection_mode    = "STANDARD"
      bgp_always_compare_med          = false
      delete_default_routes_on_create = false
    }
    subnetworks = {
      application = {
        name                             = "application-subnet"
        ip_cidr_range                    = "10.10.1.0/24"
        private_ip_google_access         = false
        send_secondary_ip_range_if_empty = true
        log_config = {
          flow_sampling = 0
          metadata      = "EXCLUDE_ALL_METADATA"
        }
        secondary_ip_range = {
          pods = {
            range_name    = "pods-range"
            ip_cidr_range = "10.20.0.0/20"
          }
          services = {
            range_name    = "services-range"
            ip_cidr_range = "10.21.0.0/24"
          }
        }
      }
    }
  }
  assert {
    condition     = google_compute_network.this.routing_mode == "GLOBAL" && google_compute_network.this.mtu == 1500 && google_compute_network.this.bgp_always_compare_med == false
    error_message = "Advanced network options and explicit false must survive."
  }
  assert {
    condition     = google_compute_subnetwork.this["application"].log_config[0].flow_sampling == 0 && !google_compute_subnetwork.this["application"].private_ip_google_access && length(google_compute_subnetwork.this["application"].secondary_ip_range) == 2
    error_message = "Zero/false values and named secondary ranges must survive."
  }
}

run "explicit_project_region_and_network" {
  command = apply
  variables {
    network = {
      name    = "unit-vpc"
      project = "host-project"
    }
    subnetworks = {
      external = {
        name          = "external-subnet"
        project       = "external-project"
        region        = "europe-west4"
        network       = "projects/external-project/global/networks/existing-vpc"
        ip_cidr_range = "10.30.0.0/24"
      }
      inherited = {
        name          = "inherited-subnet"
        ip_cidr_range = "10.31.0.0/24"
      }
    }
  }
  assert {
    condition     = output.network.project == "host-project" && output.subnetworks["inherited"].project == "host-project" && output.subnetworks["external"].project == "external-project" && output.subnetworks["external"].network == "projects/external-project/global/networks/existing-vpc"
    error_message = "Explicit references and project overrides must take precedence."
  }
}

run "reject_bad_network_name" {
  command = plan
  variables {
    network = {
      name = "INVALID_NAME"
    }
  }
  expect_failures = [var.network]
}

run "reject_bad_subnet_name" {
  command = plan
  variables {
    subnetworks = {
      application = {
        name          = "INVALID_NAME"
        ip_cidr_range = "10.0.0.0/24"
      }
    }
  }
  expect_failures = [var.subnetworks]
}

run "reject_bad_cidr" {
  command = plan
  variables {
    subnetworks = {
      application = {
        name          = "application"
        ip_cidr_range = "not-a-cidr"
      }
    }
  }
  expect_failures = [var.subnetworks]
}
