locals {
  project = "prod-common-temp"

  labels = {
    project = local.project
  }

}

inputs = {
  project = local.project
  labels  = local.labels
}
