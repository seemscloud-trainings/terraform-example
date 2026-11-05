module "router_a" {
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
  environment                           = var.environment
  router                                = var.router_a
}

module "router_b" {
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
  environment                           = var.environment
  router                                = var.router_b
}

module "gateway_a" {
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
  environment                           = var.environment
  gateway                               = var.gateway_a
}

module "gateway_b" {
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
  environment                           = var.environment
  gateway                               = var.gateway_b
}

module "tunnels" {
  source                                = "../../../vpn-tunnel"
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
  environment                           = var.environment
  shared_secrets                        = var.shared_secrets
  write_only_shared_secrets             = var.write_only_shared_secrets
  tunnels = merge(
    {
      for key, link in var.links : "a_${key}" => {
        name                  = link.name_a
        project               = module.gateway_a.gateway.project
        region                = module.gateway_a.gateway.region
        vpn_gateway           = module.gateway_a.gateway.self_link
        peer_gcp_gateway      = module.gateway_b.gateway.self_link
        vpn_gateway_interface = link.interface
        router                = module.router_a.router.self_link
        secret_key            = key
      }
    },
    {
      for key, link in var.links : "b_${key}" => {
        name                  = link.name_b
        project               = module.gateway_b.gateway.project
        region                = module.gateway_b.gateway.region
        vpn_gateway           = module.gateway_b.gateway.self_link
        peer_gcp_gateway      = module.gateway_a.gateway.self_link
        vpn_gateway_interface = link.interface
        router                = module.router_b.router.self_link
        secret_key            = key
      }
    },
  )
}

module "routing_a" {
  source                                = "../../../router-connection"
  impersonate_service_account           = var.impersonate_service_account
  impersonate_service_account_delegates = var.impersonate_service_account_delegates
  billing_project                       = var.billing_project
  user_project_override                 = var.user_project_override
  default_labels                        = var.default_labels
  request_timeout                       = var.request_timeout
  request_reason                        = var.request_reason
  universe_domain                       = var.universe_domain
  compute_custom_endpoint               = var.compute_custom_endpoint
  environment                           = var.environment
  project                               = module.router_a.router.project
  region                                = module.router_a.router.region
  router                                = module.router_a.router.name
  interfaces = {
    for key, link in var.links : key => {
      name       = link.name_a
      vpn_tunnel = module.tunnels.tunnels["a_${key}"].self_link
      ip_range   = link.ip_range_a
    }
  }
  peers = {
    for key, link in var.links : key => {
      name            = link.name_a
      interface_key   = key
      peer_asn        = module.router_b.router.asn
      peer_ip_address = split("/", link.ip_range_b)[0]
    }
  }
}

module "routing_b" {
  source                                = "../../../router-connection"
  impersonate_service_account           = var.impersonate_service_account
  impersonate_service_account_delegates = var.impersonate_service_account_delegates
  billing_project                       = var.billing_project
  user_project_override                 = var.user_project_override
  default_labels                        = var.default_labels
  request_timeout                       = var.request_timeout
  request_reason                        = var.request_reason
  universe_domain                       = var.universe_domain
  compute_custom_endpoint               = var.compute_custom_endpoint
  environment                           = var.environment
  project                               = module.router_b.router.project
  region                                = module.router_b.router.region
  router                                = module.router_b.router.name
  interfaces = {
    for key, link in var.links : key => {
      name       = link.name_b
      vpn_tunnel = module.tunnels.tunnels["b_${key}"].self_link
      ip_range   = link.ip_range_b
    }
  }
  peers = {
    for key, link in var.links : key => {
      name            = link.name_b
      interface_key   = key
      peer_asn        = module.router_a.router.asn
      peer_ip_address = split("/", link.ip_range_a)[0]
    }
  }
}

output "tunnels" {
  value     = module.tunnels.tunnels
  sensitive = true
}
