locals {
  state_path = join("/", [for segment in split("/", path_relative_to_include()) : segment if segment != "networking"])

  # Preserve existing VPC and EU-US state locations; new units use their own path.
  legacy_state_paths = {
    "env/prod/prod-common-temp/europe-west1/network/vpn-eu-vpc"              = "env/prod/prod-common-temp/europe-west1/network"
    "env/prod/prod-common-temp/us-east1/network/vpn-us-vpc"                  = "env/prod/prod-common-temp/us-east1/network"
    "env/prod/prod-common-temp/europe-west1/connections/to-us-east1/tunnels" = "env/prod/prod-common-temp/europe-west1/tunnel"
    "env/prod/prod-common-temp/europe-west1/connections/to-us-east1/bgp"     = "env/prod/prod-common-temp/europe-west1/router-config"
    "env/prod/prod-common-temp/us-east1/connections/to-europe-west1/tunnels" = "env/prod/prod-common-temp/us-east1/tunnel"
    "env/prod/prod-common-temp/us-east1/connections/to-europe-west1/bgp"     = "env/prod/prod-common-temp/us-east1/router-config"
  }
}

remote_state {
  backend = "gcs"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket = get_env("TF_STATE_BUCKET")
    # Preserve existing state keys after grouping units under networking/.
    prefix               = "terragrunt-single/${lookup(local.legacy_state_paths, local.state_path, local.state_path)}"
    skip_bucket_creation = true
  }
}
