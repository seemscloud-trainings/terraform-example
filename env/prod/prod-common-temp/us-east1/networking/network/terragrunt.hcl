include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  project = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  vpn     = read_terragrunt_config(find_in_parent_folders("vpn.hcl"))
  site    = local.vpn.locals.sites[local.region.inputs.region_name]
  peer    = local.vpn.locals.sites[local.site.peer_region]
  provider_config = {
    project = local.project.inputs.project_id
    region  = local.region.inputs.region_name
  }
}

terraform {
  source = "${get_repo_root()}//modules/network"
}

inputs = {
  provider_config = local.provider_config
  network         = { name = local.site.network_name, routing_mode = "GLOBAL" }
  subnetworks     = { main = { name = local.site.subnet_name, ip_cidr_range = local.site.cidr } }
}
