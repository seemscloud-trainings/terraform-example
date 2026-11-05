terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "= 8.10.0"
    }
  }
}

provider "google" {
  project                               = var.provider_config.project
  region                                = var.provider_config.region
  impersonate_service_account           = var.provider_config.impersonate_service_account
  impersonate_service_account_delegates = var.provider_config.impersonate_service_account_delegates
  billing_project                       = var.provider_config.billing_project
  user_project_override                 = var.provider_config.user_project_override
  default_labels                        = var.provider_config.default_labels
  request_timeout                       = var.provider_config.request_timeout
  request_reason                        = var.provider_config.request_reason
  universe_domain                       = var.provider_config.universe_domain
  compute_custom_endpoint               = var.provider_config.compute_custom_endpoint
}
