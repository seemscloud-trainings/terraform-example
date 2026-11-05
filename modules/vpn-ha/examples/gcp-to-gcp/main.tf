module "routers" {
  source                                = "../../../router"
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
  routers                               = var.routers
}

module "vpn" {
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
  gateways                              = var.gateways
  shared_secrets                        = var.shared_secrets
  write_only_shared_secrets             = var.write_only_shared_secrets
  tunnels = {
    for key, tunnel in var.tunnels : key => merge(tunnel, {
      router = module.routers.routers[var.tunnel_router_keys[key]].self_link
    })
  }
}

# Reuse the same router module to configure the routers created above.
# It creates no router of its own: ownership remains with module.routers.
module "routing" {
  source                                = "../../../router"
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
  interfaces = {
    for key, interface in var.interfaces : key => merge(interface, {
      router_key = null
      router     = module.routers.routers[interface.router_key].name
      project    = module.routers.routers[interface.router_key].project
      region     = module.routers.routers[interface.router_key].region
      vpn_tunnel = module.vpn.tunnels[var.interface_tunnel_keys[key]].self_link
    })
  }
  peers = {
    for key, peer in var.peers : key => merge(peer, {
      router_key = null
      router     = module.routers.routers[peer.router_key].name
      project    = module.routers.routers[peer.router_key].project
      region     = module.routers.routers[peer.router_key].region
    })
  }
}

output "gateways" {
  value     = module.vpn.gateways
  sensitive = true
}
output "tunnels" {
  value     = module.vpn.tunnels
  sensitive = true
}
output "peers" {
  value     = module.routing.peers
  sensitive = true
}
