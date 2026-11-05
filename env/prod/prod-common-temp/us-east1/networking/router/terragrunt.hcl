include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  project = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  vpn     = read_terragrunt_config(find_in_parent_folders("vpn.hcl"))
  site    = local.vpn.locals.sites[local.region.inputs.region]
}

terraform {
  source = "${get_repo_root()}//modules/router"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  project = local.project.inputs.project
  region  = local.region.inputs.region
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
