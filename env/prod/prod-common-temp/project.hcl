locals {
  project = "prod-common-temp"

  labels = {
    project = local.project
  }

  tags = {
    project = local.project
  }
}

inputs = {
  project = local.project
  labels  = local.labels
  tags    = local.tags
}
