include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  labels      = merge(local.environment.inputs.labels, local.project.inputs.labels)
}

terraform {
  source = "${get_repo_root()}//modules/ncc-spoke"
}

inputs = {
  environment    = local.environment.inputs.environment
  project        = local.project.inputs.project
  default_labels = local.labels
  spoke = {
    name     = "vega"
    location = "global"
    hub      = dependency.hub.outputs.hub.id
    linked_vpc_network = {
      uri                   = dependency.network.outputs.network.self_link
      include_export_ranges = [dependency.subnetwork.outputs.subnetworks.workload.ip_cidr_range]
    }
  }
}

dependency "hub" {
  config_path = "../../hub/nexus"
}

dependency "network" {
  config_path = "../../../network/vega"
}

dependency "subnetwork" {
  config_path = "${dirname(find_in_parent_folders("project.hcl"))}/us-east1/networking/subnetwork/vega"
}
