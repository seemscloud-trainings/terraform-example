module "instance" {
  source                                = "../.."
  instance                              = var.instance
  environment                           = var.environment
  project                               = var.project
  region                                = var.region
  zone                                  = var.zone
  impersonate_service_account           = var.impersonate_service_account
  impersonate_service_account_delegates = var.impersonate_service_account_delegates
  billing_project                       = var.billing_project
  user_project_override                 = var.user_project_override
  default_labels                        = var.default_labels
  request_timeout                       = var.request_timeout
  request_reason                        = var.request_reason
  universe_domain                       = var.universe_domain
  compute_custom_endpoint               = var.compute_custom_endpoint
}

output "instance" {
  value = module.instance.instance
}
