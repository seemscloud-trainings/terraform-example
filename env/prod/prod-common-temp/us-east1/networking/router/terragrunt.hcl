include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

terraform {
  source = "${get_repo_root()}//modules/router"
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
  routers = {
    main = {
      name    = "orion"
      network = dependency.network.outputs.network.self_link
      params = {
        resource_manager_tags = {
          for key, value in merge(local.environment.inputs.tags, local.project.inputs.tags, local.region.inputs.tags) : "${local.project.inputs.project}/${key}" => value
        }
      }
      bgp = {
        asn            = 65002
        advertise_mode = "DEFAULT"
      }
    }
  }
}

dependency "network" {
  config_path = "../network/main"
}
