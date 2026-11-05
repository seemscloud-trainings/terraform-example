include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
}

terraform {
  source = "${get_repo_root()}//modules/network-peering"
}

inputs = {
  environment = local.environment.inputs.environment
  project     = local.project.inputs.project
  peering = {
    name                 = "to-aurora"
    network              = dependency.network.outputs.network.self_link
    peer_network         = dependency.peer.outputs.network.self_link
    import_custom_routes = false
    export_custom_routes = false
  }
}

dependency "network" {
  config_path = "../../network/nebula"
}

dependency "peer" {
  config_path = "../../network/aurora"
}
