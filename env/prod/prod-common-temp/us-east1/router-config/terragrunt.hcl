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
dependency "router" {
  config_path                             = "../router"
  skip_outputs                            = get_env("TG_VALIDATE_ONLY", "false") == "true"
  mock_outputs_allowed_terraform_commands = ["validate", "render"]
  mock_outputs = {
    routers = { main = {
      name      = local.site.router_name
      project   = local.project.inputs.project_id
      region    = local.region.inputs.region_name
      self_link = "https://www.googleapis.com/compute/v1/projects/${local.project.inputs.project_id}/regions/${local.region.inputs.region_name}/routers/${local.site.router_name}"
    } }
  }
}
dependency "tunnel" {
  config_path                             = "../tunnel"
  skip_outputs                            = get_env("TG_VALIDATE_ONLY", "false") == "true"
  mock_outputs_allowed_terraform_commands = ["validate", "render"]
  mock_outputs = {
    tunnels = { for key, tunnel in local.site.tunnels : key => {
      name      = tunnel.name
      self_link = "https://www.googleapis.com/compute/v1/projects/${local.project.inputs.project_id}/regions/${local.region.inputs.region_name}/vpnTunnels/${tunnel.name}"
    } }
  }
}
inputs = {
  provider_config = local.provider_config
  # No routers map: this unit owns only interfaces and peers on the existing router.
  interfaces = { for key, tunnel in local.site.tunnels : key => {
    name       = tunnel.interface_name
    router     = dependency.router.outputs.routers.main.name
    vpn_tunnel = dependency.tunnel.outputs.tunnels[key].self_link
    ip_range   = tunnel.ip_range
  } }
  peers = { for key, tunnel in local.site.tunnels : key => {
    name            = tunnel.peer_name
    router          = dependency.router.outputs.routers.main.name
    interface_key   = key
    peer_asn        = local.peer.asn
    peer_ip_address = tunnel.peer_ip_address
    advertise_mode  = "DEFAULT"
  } }
}
