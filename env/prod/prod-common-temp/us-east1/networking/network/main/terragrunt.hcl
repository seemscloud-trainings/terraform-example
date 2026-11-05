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
  source = "${get_repo_root()}//modules/network"
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
  network = {
    name         = "orion"
    routing_mode = "GLOBAL"
    params = {
      resource_manager_tags = {
        for key, value in merge(local.environment.inputs.tags, local.project.inputs.tags) : dependency.tags.outputs.keys[key] => dependency.tags.outputs.values["${key}/${value}"]
      }
    }
  }
  subnetworks = {
    main = {
      name = "orion"
      params = {
        resource_manager_tags = {
          for key, value in merge(local.environment.inputs.tags, local.project.inputs.tags, local.region.inputs.tags) : dependency.tags.outputs.keys[key] => dependency.tags.outputs.values["${key}/${value}"]
        }
      }
      ip_cidr_range = "10.81.0.0/24"
    }
  }
}

dependency "tags" {
  config_path = "${dirname(find_in_parent_folders("project.hcl"))}/tags"
}
