module "network" {
  source          = "../.."
  provider_config = var.provider_config
  network         = var.network
  subnetworks     = var.subnetworks
}

output "network" {
  value = module.network.network
}
output "subnetworks" {
  value = module.network.subnetworks
}
