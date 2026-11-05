remote_state {
  backend = "gcs"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket               = get_env("TF_STATE_BUCKET")
    prefix               = "terragrunt-single/${path_relative_to_include()}"
    skip_bucket_creation = true
  }
}
