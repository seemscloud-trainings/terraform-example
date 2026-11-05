variable "environment" {
  type        = string
  default     = null
  description = "Environment context supplied by the caller. Does not modify explicit resource names."
}

variable "project" {
  type        = string
  nullable    = false
  description = "Default GCP project; individual resources may override it."
}

variable "region" {
  type        = string
  default     = null
  description = "Optional Google provider region setting."
}

variable "impersonate_service_account" {
  type        = string
  default     = null
  description = "Optional Google provider impersonate_service_account setting."
}

variable "impersonate_service_account_delegates" {
  type        = list(string)
  default     = null
  description = "Optional Google provider impersonate_service_account_delegates setting."
}

variable "billing_project" {
  type        = string
  default     = null
  description = "Optional Google provider billing_project setting."
}

variable "user_project_override" {
  type        = bool
  default     = null
  description = "Optional Google provider user_project_override setting."
}

variable "default_labels" {
  type        = map(string)
  default     = null
  description = "Optional Google provider default_labels setting."
}

variable "request_timeout" {
  type        = string
  default     = null
  description = "Optional Google provider request_timeout setting."
}

variable "request_reason" {
  type        = string
  default     = null
  description = "Optional Google provider request_reason setting."
}

variable "universe_domain" {
  type        = string
  default     = null
  description = "Optional Google provider universe_domain setting."
}

variable "compute_custom_endpoint" {
  type        = string
  default     = null
  description = "Optional Google provider compute_custom_endpoint setting."
}


variable "routers" {
  type = map(object({
    deletion_policy               = optional(string)
    description                   = optional(string)
    encrypted_interconnect_router = optional(bool)
    name                          = string
    ncc_gateway                   = optional(string)
    network                       = optional(string)
    project                       = optional(string)
    region                        = optional(string)
    bgp = optional(object({
      advertise_mode     = optional(string)
      advertised_groups  = optional(list(string))
      asn                = number
      identifier_range   = optional(string)
      keepalive_interval = optional(number)
      advertised_ip_ranges = optional(map(object({
        description = optional(string)
        range       = string
      })), {})
    }))
    md5_authentication_keys = optional(object({
      key  = string
      name = string
    }))
    params = optional(object({
      resource_manager_tags = optional(map(string))
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  nullable    = false
  description = "router configurations keyed by stable logical identifiers; every name is supplied unchanged by the caller."
}

variable "interfaces" {
  type = map(object({
    deletion_policy         = optional(string)
    interconnect_attachment = optional(string)
    ip_range                = optional(string)
    ip_version              = optional(string)
    name                    = string
    private_ip_address      = optional(string)
    project                 = optional(string)
    redundant_interface     = optional(string)
    region                  = optional(string)
    router                  = optional(string)
    subnetwork              = optional(string)
    vpn_tunnel              = optional(string)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
    }))
    router_key = optional(string)
  }))
  default     = {}
  nullable    = false
  description = "router_interface configurations keyed by stable logical identifiers; every name is supplied unchanged by the caller."
}

variable "peers" {
  type = map(object({
    advertise_mode                     = optional(string)
    advertised_groups                  = optional(list(string))
    advertised_route_priority          = optional(number)
    custom_learned_route_priority      = optional(number)
    deletion_policy                    = optional(string)
    enable                             = optional(bool)
    enable_ipv4                        = optional(bool)
    enable_ipv6                        = optional(bool)
    export_policies                    = optional(list(string))
    import_policies                    = optional(list(string))
    interface                          = optional(string)
    ip_address                         = optional(string)
    ipv4_nexthop_address               = optional(string)
    ipv6_nexthop_address               = optional(string)
    name                               = string
    peer_asn                           = number
    peer_ip_address                    = optional(string)
    peer_ipv4_nexthop_address          = optional(string)
    peer_ipv6_nexthop_address          = optional(string)
    project                            = optional(string)
    region                             = optional(string)
    router                             = optional(string)
    router_appliance_instance          = optional(string)
    zero_advertised_route_priority     = optional(bool)
    zero_custom_learned_route_priority = optional(bool)
    advertised_ip_ranges = optional(map(object({
      description = optional(string)
      range       = string
    })), {})
    bfd = optional(object({
      min_receive_interval        = optional(number)
      min_transmit_interval       = optional(number)
      multiplier                  = optional(number)
      session_initialization_mode = string
    }))
    custom_learned_ip_ranges = optional(map(object({
      range = string
    })), {})
    md5_authentication_key = optional(object({
      key  = string
      name = string
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
    router_key    = optional(string)
    interface_key = optional(string)
  }))
  default     = {}
  nullable    = false
  description = "router_peer configurations keyed by stable logical identifiers; every name is supplied unchanged by the caller."
}

variable "gateways" {
  type = map(object({
    deletion_policy    = optional(string)
    description        = optional(string)
    gateway_ip_version = optional(string)
    labels             = optional(map(string))
    name               = string
    network            = string
    project            = optional(string)
    region             = optional(string)
    stack_type         = optional(string)
    params = optional(object({
      resource_manager_tags = optional(map(string))
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
    vpn_interfaces = optional(map(object({
      id                      = optional(number)
      interconnect_attachment = optional(string)
    })), {})
  }))
  default     = {}
  nullable    = false
  description = "ha_vpn_gateway configurations keyed by stable logical identifiers; every name is supplied unchanged by the caller."
}

variable "tunnels" {
  type = map(object({
    deletion_policy                 = optional(string)
    description                     = optional(string)
    ike_version                     = optional(number, 2)
    labels                          = optional(map(string))
    local_traffic_selector          = optional(set(string))
    name                            = string
    peer_external_gateway           = optional(string)
    peer_external_gateway_interface = optional(number)
    peer_gcp_gateway                = optional(string)
    project                         = optional(string)
    region                          = optional(string)
    remote_traffic_selector         = optional(set(string))
    router                          = optional(string)
    shared_secret_wo_version        = optional(string)
    vpn_gateway                     = optional(string)
    vpn_gateway_interface           = optional(number)
    cipher_suite = optional(object({
      phase1 = optional(object({
        dh         = optional(list(string))
        encryption = optional(list(string))
        integrity  = optional(list(string))
        prf        = optional(list(string))
      }))
      phase2 = optional(object({
        encryption = optional(list(string))
        integrity  = optional(list(string))
        pfs        = optional(list(string))
      }))
    }))
    params = optional(object({
      resource_manager_tags = optional(map(string))
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
    gateway_key      = optional(string)
    peer_gateway_key = optional(string)
    secret_key       = optional(string)
    secret_mode      = optional(string, "standard")
  }))
  default     = {}
  nullable    = false
  description = "vpn_tunnel configurations keyed by stable logical identifiers; every name is supplied unchanged by the caller."
}

variable "shared_secrets" {
  type        = map(string)
  default     = {}
  nullable    = false
  sensitive   = true
  description = "PSKs for standard mode. Keys are selected by tunnel secret_key (or tunnel map key). Standard PSKs are stored in Terraform state."
}

variable "write_only_shared_secrets" {
  type        = map(string)
  default     = {}
  nullable    = false
  sensitive   = true
  ephemeral   = true
  description = "Ephemeral PSKs for write_only mode; set shared_secret_wo_version on the tunnel and increment it for rotation."
}
variable "tunnel_router_keys" {
  type = map(string)
}
variable "interface_tunnel_keys" {
  type = map(string)
}
