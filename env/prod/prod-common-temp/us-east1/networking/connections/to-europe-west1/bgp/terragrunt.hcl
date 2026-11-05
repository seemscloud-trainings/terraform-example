include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  project           = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region            = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  vpn               = read_terragrunt_config(find_in_parent_folders("vpn.hcl"))
  connection_config = read_terragrunt_config(find_in_parent_folders("connection.hcl"))
  connection        = local.vpn.locals.connections[local.connection_config.locals.connection_key]
  site              = local.vpn.locals.sites[local.region.inputs.region_name]
  endpoint          = local.connection.endpoints[local.region.inputs.region_name]
  peer_region       = one([for region in keys(local.connection.endpoints) : region if region != local.region.inputs.region_name])
  peer              = local.vpn.locals.sites[local.peer_region]
  provider_config = {
    project = local.project.inputs.project_id
    region  = local.region.inputs.region_name
  }
}

terraform {
  source = "${get_repo_root()}//modules/router"
}

dependency "router" {
  config_path = "../../../router"
}

dependency "tunnel" {
  config_path = "../tunnels"
}

inputs = {
  provider_config = local.provider_config
  # No routers map: this unit owns only interfaces and peers on the existing router.
  interfaces = { for key, tunnel in local.endpoint.tunnels : key => {
    name       = tunnel.interface_name
    router     = dependency.router.outputs.routers.main.name
    vpn_tunnel = dependency.tunnel.outputs.tunnels[key].self_link
    ip_range   = tunnel.ip_range
  } }
  peers = { for key, tunnel in local.endpoint.tunnels : key => {
    name            = tunnel.peer_name
    router          = dependency.router.outputs.routers.main.name
    interface_key   = key
    peer_asn        = local.peer.asn
    peer_ip_address = tunnel.peer_ip_address
    advertise_mode  = "DEFAULT"
  } }
}
