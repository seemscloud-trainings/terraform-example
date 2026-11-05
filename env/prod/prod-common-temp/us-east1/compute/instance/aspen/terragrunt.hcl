include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  ssh_key     = trimspace(file(find_in_parent_folders("taw.pub")))
  labels      = merge(local.environment.inputs.labels, local.project.inputs.labels, local.region.inputs.labels)
}

terraform {
  source = "${get_repo_root()}//modules/instance"
}

inputs = {
  environment    = local.environment.inputs.environment
  project        = local.project.inputs.project
  region         = local.region.inputs.region
  default_labels = local.labels
  zone           = "us-east1-b"
  instance = {
    name         = "aspen"
    machine_type = "e2-micro"
    tags = [
      "ssh",
    ]
    boot_disk = {
      initialize_params = {
        image  = "projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2604-resolute-amd64-v20261104a"
        size   = 10
        type   = "pd-standard"
        labels = local.labels
      }
    }
    network_interface = [

      {
        subnetwork = dependency.subnetwork.outputs.subnetworks.workload.self_link
        access_config = {
          public = {
            network_tier = "PREMIUM"
          }
        }
      }
      ,
    ]
    metadata = {
      enable-oslogin         = "FALSE"
      block-project-ssh-keys = "TRUE"
      ssh-keys               = "taw:${local.ssh_key}"
    }
  }
}

dependency "subnetwork" {
  config_path = "../../../networking/subnetwork/nebula"
}
