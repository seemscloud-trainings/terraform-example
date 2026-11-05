include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  connection  = read_terragrunt_config(find_in_parent_folders("connection.hcl")).locals
}

terraform {
  source = "${get_repo_root()}//modules/router"
}

inputs = {
  environment = local.environment.inputs.environment
  project     = local.project.inputs.project
  region      = local.region.inputs.region
  # No routers map: this unit owns only interfaces and peers on the existing router.
  interfaces = {
    for key, tunnel in local.connection.tunnels : key => {
      name       = tunnel.interface_name
      router     = dependency.router.outputs.routers.main.name
      vpn_tunnel = dependency.tunnel.outputs.tunnels[key].self_link
      ip_range   = tunnel.ip_range
    }
  }
  peers = {
    for key, tunnel in local.connection.tunnels : key => {
      name            = tunnel.peer_name
      router          = dependency.router.outputs.routers.main.name
      interface_key   = key
      peer_asn        = dependency.peer_router.outputs.routers.main.asn
      peer_ip_address = tunnel.peer_ip_address
      advertise_mode  = "DEFAULT"
    }
  }
}

dependency "router" {
  config_path = "../../../router"
}

dependency "peer_router" {
  config_path = "${dirname(find_in_parent_folders("project.hcl"))}/${local.connection.peer_region}/networking/router"
}

dependency "tunnel" {
  config_path = "../tunnels"
}
