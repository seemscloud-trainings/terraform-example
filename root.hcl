remote_state {
  backend = "gcs"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket = get_env("TF_STATE_BUCKET")
    # Preserve existing state keys after grouping units under networking/.
    prefix               = "terragrunt-single/${join("/", [for segment in split("/", path_relative_to_include()) : segment if segment != "networking"])}"
    skip_bucket_creation = true
  }
}
