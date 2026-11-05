module "router" {
  source          = "../.."
  provider_config = var.provider_config
  routers         = var.routers
}
output "routers" {
  value     = module.router.routers
  sensitive = true
}
