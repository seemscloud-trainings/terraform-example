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
  source = "${get_repo_root()}//modules/network"
}

inputs = {
  project     = local.project.inputs.project
  region      = local.region.inputs.region
  network     = { name = local.site.network_name, routing_mode = "GLOBAL" }
  subnetworks = { main = { name = local.site.subnet_name, ip_cidr_range = local.site.cidr } }
}
