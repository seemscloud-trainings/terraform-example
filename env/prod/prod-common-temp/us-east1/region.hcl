locals {
  region = "us-east1"

  labels = {
    region = local.region
  }

}

inputs = {
  region = local.region
  labels = local.labels
}
