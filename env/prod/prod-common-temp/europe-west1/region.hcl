locals {
  region = "europe-west1"

  labels = {
    region = local.region
  }

  tags = {
    region = local.region
  }
}

inputs = {
  region = local.region
  labels = local.labels
  tags   = local.tags
}
