include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
}

terraform {
  source = "${get_repo_root()}//modules/firewall"
}

inputs = {
  environment = local.environment.inputs.environment
  project     = local.project.inputs.project
  firewall = {
    name      = "birch"
    network   = dependency.network.outputs.network.self_link
    direction = "INGRESS"
    priority  = 1000
    source_ranges = [
      "0.0.0.0/0",
    ]
    target_tags = [
      "ssh",
    ]
    allow = {
      ssh = {
        protocol = "tcp"
        ports = [
          "22",
        ]
      }
    }
  }
}

dependency "network" {
  config_path = "../../network/lyra"
}
