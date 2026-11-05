module "network" {
  environment                           = var.environment
  source                                = "../.."
  project                               = var.project
  region                                = var.region
  impersonate_service_account           = var.impersonate_service_account
  impersonate_service_account_delegates = var.impersonate_service_account_delegates
  billing_project                       = var.billing_project
  user_project_override                 = var.user_project_override
  default_labels                        = var.default_labels
  request_timeout                       = var.request_timeout
  request_reason                        = var.request_reason
  universe_domain                       = var.universe_domain
  compute_custom_endpoint               = var.compute_custom_endpoint
  network                               = var.network
  subnetworks                           = var.subnetworks
}

output "network" {
  value = module.network.network
}
output "subnetworks" {
  value = module.network.subnetworks
}
