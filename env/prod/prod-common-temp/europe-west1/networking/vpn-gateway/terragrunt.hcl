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
  source = "${get_repo_root()}//modules/vpn-ha"
}

inputs = {
  environment = local.environment.inputs.environment
  project     = local.project.inputs.project
  region      = local.region.inputs.region
  gateways = {
    main = {
      name               = "vpn-eu-gateway"
      network            = dependency.network.outputs.network.self_link
      gateway_ip_version = "IPV4"
      stack_type         = "IPV4_ONLY"
    }
  }
}

dependency "network" {
  config_path = "../network/main"
}
