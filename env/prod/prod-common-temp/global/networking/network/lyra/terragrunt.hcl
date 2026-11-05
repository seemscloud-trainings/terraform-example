include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  labels      = merge(local.environment.inputs.labels, local.project.inputs.labels)
}

terraform {
  source = "${get_repo_root()}//modules/network"
}

inputs = {
  environment    = local.environment.inputs.environment
  project        = local.project.inputs.project
  default_labels = local.labels
  network = {
    name         = "lyra"
    routing_mode = "GLOBAL"
  }
}
