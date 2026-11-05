locals {
  environment = "prod"

  labels = {
    environment = local.environment
  }

  tags = {
    environment = local.environment
  }
}

inputs = {
  environment = local.environment
  labels      = local.labels
  tags        = local.tags
}
