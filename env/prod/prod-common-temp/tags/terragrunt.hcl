include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform_binary = "terraform"

locals {
  environment   = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  project       = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  project_dir   = dirname(find_in_parent_folders("project.hcl"))
  regional_tags = [for path in sort(tolist(fileset(local.project_dir, "*/region.hcl"))) : read_terragrunt_config("${local.project_dir}/${path}").inputs.tags]
  tag_sets      = concat([local.environment.inputs.tags, local.project.inputs.tags], local.regional_tags)
  tag_names     = toset(flatten([for tags in local.tag_sets : keys(tags)]))
  tag_values = merge([for tags in local.tag_sets : {
    for key, value in tags : "${key}/${value}" => {
      key        = key
      short_name = value
    }
  }]...)
}

terraform {
  source = "${get_repo_root()}//modules/tags"
}

inputs = {
  environment = local.environment.inputs.environment
  project     = local.project.inputs.project
  keys = {
    for name in local.tag_names : name => {
      parent     = "projects/${local.project.inputs.project}"
      short_name = name
    }
  }
  values = local.tag_values
}
