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
  validation {
    condition     = alltrue([for v in values(var.tunnels) : can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", v.name))])
    error_message = "Names must be valid GCP resource names (1-63 lowercase letters/digits/hyphens)."
  }
  validation {
    condition     = alltrue([for v in values(var.tunnels) : (v.vpn_gateway != null) != (v.gateway_key != null)])
    error_message = "Supply exactly one of vpn_gateway or gateway_key; Classic VPN gateways are not supported."
  }
  validation {
    condition     = alltrue([for v in values(var.tunnels) : v.gateway_key == null ? true : contains(keys(var.gateways), v.gateway_key)])
    error_message = "gateway_key must identify a gateway created by this module."
  }
  validation {
    condition     = alltrue([for v in values(var.tunnels) : length([for x in [v.peer_gcp_gateway, v.peer_gateway_key, v.peer_external_gateway] : x if x != null]) == 1])
    error_message = "Supply exactly one peer_gcp_gateway, peer_gateway_key or peer_external_gateway."
  }
  validation {
    condition     = alltrue([for v in values(var.tunnels) : v.peer_gateway_key == null ? true : contains(keys(var.gateways), v.peer_gateway_key)])
    error_message = "peer_gateway_key must identify a gateway created by this module."
  }
  validation {
    condition     = alltrue([for v in values(var.tunnels) : v.vpn_gateway_interface == null ? false : contains([0, 1], v.vpn_gateway_interface)])
    error_message = "Specify HA gateway interface 0 or 1 for every tunnel."
  }
  validation {
    condition     = alltrue([for v in values(var.tunnels) : v.router != null])
    error_message = "HA VPN requires an existing Cloud Router; supply its name or self-link."
  }
  validation {
    condition     = alltrue([for v in values(var.tunnels) : contains([1, 2], v.ike_version)])
    error_message = "ike_version must be 1 or 2."
  }
  validation {
    condition     = alltrue([for v in values(var.tunnels) : contains(["standard", "write_only"], v.secret_mode)])
    error_message = "secret_mode must be standard or write_only."
  }
  validation {
    condition     = alltrue([for v in values(var.tunnels) : v.secret_mode != "write_only" || v.shared_secret_wo_version != null])
    error_message = "Write-only secrets require shared_secret_wo_version; increment it to rotate the PSK."
  }
  validation {
    condition     = alltrue([for k, v in var.tunnels : v.secret_mode != "standard" || contains(keys(var.shared_secrets), v.secret_key != null ? v.secret_key : k)])
    error_message = "Every standard-mode tunnel needs a shared_secrets entry, selected by secret_key or its map key."
  }
  validation {
    condition = alltrue([for v in values(var.tunnels) :
      (v.peer_external_gateway != null) == (v.peer_external_gateway_interface != null)
    ])
    error_message = "peer_external_gateway_interface is required only for an external peer gateway."
  }
  validation {
    condition = alltrue([for v in values(var.tunnels) :
      v.gateway_key == null || v.peer_gateway_key == null || v.gateway_key != v.peer_gateway_key
    ])
    error_message = "A tunnel cannot connect a gateway to itself."
  }
}
