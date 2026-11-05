include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  labels      = merge(local.environment.inputs.labels, local.project.inputs.labels, local.region.inputs.labels)
}

terraform {
  source = "${get_repo_root()}//modules/subnetwork"
}

inputs = {
  environment    = local.environment.inputs.environment
  project        = local.project.inputs.project
  region         = local.region.inputs.region
  default_labels = local.labels
  subnetworks = {
    workload = {
      name          = "aurora"
      network       = dependency.network.outputs.network.self_link
      ip_cidr_range = "10.94.0.0/24"
    }
  }
}

dependency "network" {
  config_path = "${dirname(find_in_parent_folders("project.hcl"))}/global/networking/network/aurora"
}
