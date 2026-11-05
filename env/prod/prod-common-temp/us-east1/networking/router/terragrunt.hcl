include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  project = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  vpn     = read_terragrunt_config(find_in_parent_folders("vpn.hcl"))
  site    = local.vpn.locals.sites[local.region.inputs.region_name]
  provider_config = {
    project = local.project.inputs.project_id
    region  = local.region.inputs.region_name
  }
}

terraform {
  source = "${get_repo_root()}//modules/router"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  provider_config = local.provider_config
  routers = { main = {
    name    = local.site.router_name
    network = dependency.network.outputs.network.self_link
    bgp     = { asn = local.site.asn, advertise_mode = "DEFAULT" }
  } }
}
