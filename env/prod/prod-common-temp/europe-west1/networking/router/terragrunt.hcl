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
  source = "${get_repo_root()}//modules/router"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  environment = local.environment.inputs.environment
  project     = local.project.inputs.project
  region      = local.region.inputs.region
  routers = {
    main = {
      name    = local.site.router_name
      network = dependency.network.outputs.network.self_link
      bgp = {
        asn            = local.site.asn
        advertise_mode = "DEFAULT"
      }
    }
  }
}
