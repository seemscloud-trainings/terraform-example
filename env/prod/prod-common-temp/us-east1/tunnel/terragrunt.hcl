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
  source = "${get_repo_root()}//modules/vpn-ha"
  extra_arguments "vpn_secrets" {
    commands           = get_terraform_commands_that_need_vars()
    required_var_files = [get_env("VPN_SECRETS_FILE", "${get_repo_root()}/vpn.secrets.tfvars")]
  }
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

dependency "gateway" {
  config_path                             = "../vpn-gateway"
  skip_outputs                            = get_env("TG_VALIDATE_ONLY", "false") == "true"
  mock_outputs_allowed_terraform_commands = ["validate", "render"]
  mock_outputs = {
    gateways = { main = {
      name      = local.site.gateway_name
      self_link = "https://www.googleapis.com/compute/v1/projects/${local.project.inputs.project_id}/regions/${local.region.inputs.region_name}/vpnGateways/${local.site.gateway_name}"
    } }
  }
}

dependency "peer_gateway" {
  config_path                             = "../../${local.site.peer_region}/vpn-gateway"
  skip_outputs                            = get_env("TG_VALIDATE_ONLY", "false") == "true"
  mock_outputs_allowed_terraform_commands = ["validate", "render"]
  mock_outputs = {
    gateways = { main = {
      name      = local.peer.gateway_name
      self_link = "https://www.googleapis.com/compute/v1/projects/${local.project.inputs.project_id}/regions/${local.site.peer_region}/vpnGateways/${local.peer.gateway_name}"
    } }
  }
}

inputs = {
  provider_config = local.provider_config
  tunnels = { for key, tunnel in local.site.tunnels : key => {
    name                  = tunnel.name
    vpn_gateway           = dependency.gateway.outputs.gateways.main.self_link
    peer_gcp_gateway      = dependency.peer_gateway.outputs.gateways.main.self_link
    vpn_gateway_interface = tunnel.interface
    router                = dependency.router.outputs.routers.main.self_link
    ike_version           = 2
    secret_key            = key
  } }
}
