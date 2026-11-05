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
  source = "${get_repo_root()}//modules/vpn-ha"
  extra_arguments "vpn_secrets" {
    commands           = get_terraform_commands_that_need_vars()
    required_var_files = [get_env("VPN_SECRETS_FILE", "${get_repo_root()}/${local.connection.secrets_file}")]
  }
}

inputs = {
  environment = local.environment.inputs.environment
  project     = local.project.inputs.project
  region      = local.region.inputs.region
  default_labels = merge(
    local.environment.inputs.labels,
    local.project.inputs.labels,
    local.region.inputs.labels,
  )
  tunnels = {
    for key, tunnel in local.connection.tunnels : key => {
      name                  = tunnel.name
      vpn_gateway           = dependency.gateway.outputs.gateways.main.self_link
      peer_gcp_gateway      = dependency.peer_gateway.outputs.gateways.main.self_link
      vpn_gateway_interface = tunnel.interface
      router                = dependency.router.outputs.routers.main.self_link
      ike_version           = 2
      params = {
        resource_manager_tags = {
          for key, value in merge(local.environment.inputs.tags, local.project.inputs.tags, local.region.inputs.tags) : "${local.project.inputs.project}/${key}" => value
        }
      }
      secret_key = key
    }
  }
}

dependency "router" {
  config_path = "../../../router"
}

dependency "gateway" {
  config_path = "../../../vpn-gateway"
}

dependency "peer_gateway" {
  config_path = "${dirname(find_in_parent_folders("project.hcl"))}/${local.connection.peer_region}/networking/vpn-gateway"
}
