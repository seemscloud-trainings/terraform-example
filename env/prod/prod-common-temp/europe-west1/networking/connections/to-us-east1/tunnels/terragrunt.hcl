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
  site              = local.vpn.locals.sites[local.region.inputs.region]
  endpoint          = local.connection.endpoints[local.region.inputs.region]
  peer_region       = one([for region in keys(local.connection.endpoints) : region if region != local.region.inputs.region])
  peer              = local.vpn.locals.sites[local.peer_region]
}

terraform {
  source = "${get_repo_root()}//modules/vpn-ha"
  extra_arguments "vpn_secrets" {
    commands           = get_terraform_commands_that_need_vars()
    required_var_files = [get_env("VPN_SECRETS_FILE", "${get_repo_root()}/${local.connection.secrets_file}")]
  }
}

dependency "router" {
  config_path = "../../../router"
}

dependency "gateway" {
  config_path = "../../../vpn-gateway"
}

dependency "peer_gateway" {
  config_path = "${dirname(find_in_parent_folders("project.hcl"))}/${local.peer_region}/networking/vpn-gateway"
}

inputs = {
  project = local.project.inputs.project
  region  = local.region.inputs.region
  tunnels = { for key, tunnel in local.endpoint.tunnels : key => {
    name                  = tunnel.name
    vpn_gateway           = dependency.gateway.outputs.gateways.main.self_link
    peer_gcp_gateway      = dependency.peer_gateway.outputs.gateways.main.self_link
    vpn_gateway_interface = tunnel.interface
    router                = dependency.router.outputs.routers.main.self_link
    ike_version           = 2
    secret_key            = key
  } }
}
