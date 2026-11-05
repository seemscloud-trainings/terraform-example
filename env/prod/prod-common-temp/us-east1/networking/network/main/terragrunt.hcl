include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

terraform {
  source = "${get_repo_root()}//modules/network"
}

inputs = {
  environment = local.environment.inputs.environment
  project     = local.project.inputs.project
  region      = local.region.inputs.region
  network = {
    name         = "prod-us-east1-main-vpc"
    routing_mode = "GLOBAL"
  }
  subnetworks = {
    main = {
      name          = "prod-us-east1-main-subnet"
      ip_cidr_range = "10.81.0.0/24"
    }
  }
}
