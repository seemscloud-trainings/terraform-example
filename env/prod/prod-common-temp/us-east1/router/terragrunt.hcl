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
  source = "${get_repo_root()}//modules/router"
}
dependency "network" {
  config_path                             = "../network"
  skip_outputs                            = get_env("TG_VALIDATE_ONLY", "false") == "true"
  mock_outputs_allowed_terraform_commands = ["validate", "render"]
  mock_outputs = {
    network = {
      name      = local.site.network_name
      self_link = "https://www.googleapis.com/compute/v1/projects/${local.project.inputs.project_id}/global/networks/${local.site.network_name}"
    }
  }
}
inputs = {
  provider_config = local.provider_config
  routers = { main = {
    name    = local.site.router_name
    network = dependency.network.outputs.network.self_link
    bgp     = { asn = local.site.asn, advertise_mode = "DEFAULT" }
  } }
}
