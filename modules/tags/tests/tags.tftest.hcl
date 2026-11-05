mock_provider "google" {}

variables {
  project = "test-project"
  keys = {
    environment = {
      parent     = "projects/test-project"
      short_name = "environment"
    }
  }
  values = {
    prod = {
      key        = "environment"
      short_name = "prod"
    }
  }
}

run "managed" {
  command = apply

  assert {
    condition     = google_tags_tag_value.this["prod"].parent == output.keys["environment"] && output.values["prod"] == google_tags_tag_value.this["prod"].id
    error_message = "Values must resolve to the managed key and expose resource IDs."
  }
}

run "add_value" {
  command = apply

  variables {
    values = {
      prod = {
        key        = "environment"
        short_name = "prod"
      }
      stage = {
        key        = "environment"
        short_name = "stage"
      }
    }
  }

  assert {
    condition     = output.values["prod"] == run.managed.values["prod"] && length(output.values) == 2
    error_message = "Adding a tag value must preserve existing identity."
  }
}

run "external_key" {
  command = plan

  variables {
    keys = {}
    values = {
      prod = {
        parent     = "tagKeys/123"
        short_name = "prod"
      }
    }
  }

  assert {
    condition     = google_tags_tag_value.this["prod"].parent == "tagKeys/123"
    error_message = "Existing key IDs must be usable."
  }
}
