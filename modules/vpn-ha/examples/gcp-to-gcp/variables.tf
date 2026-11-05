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

variable "environment" {
  type        = string
  default     = null
  description = "Environment context supplied by the caller. Does not modify explicit resource names."
}

variable "router_a" {
  type = object({
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
  })
  nullable    = false
  description = "One Cloud Router; the explicit name is used unchanged."
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", var.router_a.name))
    error_message = "Names must be valid GCP resource names (1-63 lowercase letters/digits/hyphens)."
  }
}

variable "router_b" {
  type = object({
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
  })
  nullable    = false
  description = "One Cloud Router; the explicit name is used unchanged."
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", var.router_b.name))
    error_message = "Names must be valid GCP resource names (1-63 lowercase letters/digits/hyphens)."
  }
}

variable "gateway_a" {
  type = object({
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
  })
  nullable    = false
  description = "One HA VPN gateway; the explicit name is used unchanged."
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", var.gateway_a.name))
    error_message = "Names must be valid GCP resource names (1-63 lowercase letters/digits/hyphens)."
  }
}

variable "gateway_b" {
  type = object({
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
  })
  nullable    = false
  description = "One HA VPN gateway; the explicit name is used unchanged."
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", var.gateway_b.name))
    error_message = "Names must be valid GCP resource names (1-63 lowercase letters/digits/hyphens)."
  }
}

variable "shared_secrets" {
  type        = map(string)
  default     = {}
  nullable    = false
  sensitive   = true
  description = "PSKs for standard mode. Keys are selected by tunnel secret_key (or tunnel map key). Standard PSKs are stored in Terraform state."
  validation {
    condition = alltrue([
      for secret in values(var.shared_secrets) : length(secret) > 0
    ])
    error_message = "PSKs must not be empty."
  }
}

variable "write_only_shared_secrets" {
  type        = map(string)
  default     = {}
  nullable    = false
  sensitive   = true
  ephemeral   = true
  description = "Ephemeral PSKs for write_only mode; set shared_secret_wo_version on the tunnel and increment it for rotation."
  validation {
    condition = alltrue([
      for secret in values(var.write_only_shared_secrets) : length(secret) > 0
    ])
    error_message = "PSKs must not be empty."
  }
}

variable "links" {
  type = map(object({
    interface  = number
    name_a     = string
    name_b     = string
    ip_range_a = string
    ip_range_b = string
  }))
  nullable = false
}
