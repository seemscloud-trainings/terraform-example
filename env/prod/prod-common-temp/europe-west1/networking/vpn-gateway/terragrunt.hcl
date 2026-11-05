include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  site        = read_terragrunt_config(find_in_parent_folders("networking.hcl")).locals
}

terraform {
  source = "${get_repo_root()}//modules/vpn-ha"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  environment = local.environment.inputs.environment
  project     = local.project.inputs.project
  region      = local.region.inputs.region
  gateways = {
    main = {
      name               = local.site.gateway_name
      network            = dependency.network.outputs.network.self_link
      gateway_ip_version = "IPV4"
      stack_type         = "IPV4_ONLY"
    }
  }
}
