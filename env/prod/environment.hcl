locals {
  environment = "prod"

  labels = {
    environment = local.environment
  }

}

inputs = {
  environment = local.environment
  labels      = local.labels
}
