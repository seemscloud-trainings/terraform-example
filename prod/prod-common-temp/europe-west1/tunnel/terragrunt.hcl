# Placeholder only; VPN resources will be added in the next step.
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

terraform {
  source = "git::ssh://git@github.com/seemscloud-trainings/terraform-modules.git//null-resources?ref=4066d5360d37fb656bf1051901d79d69b7219228"
}

locals {
  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project     = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  region      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

inputs = merge(
  local.environment.inputs,
  local.project.inputs,
  local.region.inputs,
  {
    name   = "tunnel"
    prefix = local.project.inputs.project_name

    labels = {
      cloud       = "gcp"
      application = "vpn"
      component   = "tunnel"
    }
  }
)
