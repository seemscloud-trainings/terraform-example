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
    name         = "atlas"
    routing_mode = "GLOBAL"
    params = {
      resource_manager_tags = {
        for key, value in merge(local.environment.inputs.tags, local.project.inputs.tags) : "${local.project.inputs.project}/${key}" => value
      }
    }
  }
  subnetworks = {
    main = {
      name = "atlas"
      params = {
        resource_manager_tags = {
          for key, value in merge(local.environment.inputs.tags, local.project.inputs.tags, local.region.inputs.tags) : "${local.project.inputs.project}/${key}" => value
        }
      }
      ip_cidr_range = "10.80.0.0/24"
    }
  }
}
