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


variable "network" {
  type = object({
    auto_create_subnetworks                   = optional(bool, false)
    bgp_always_compare_med                    = optional(bool)
    bgp_best_path_selection_mode              = optional(string)
    bgp_inter_region_cost                     = optional(string)
    delete_bgp_always_compare_med             = optional(bool)
    delete_default_routes_on_create           = optional(bool)
    deletion_policy                           = optional(string)
    description                               = optional(string)
    enable_ula_internal_ipv6                  = optional(bool)
    internal_ipv6_range                       = optional(string)
    mtu                                       = optional(number)
    name                                      = string
    network_firewall_policy_enforcement_order = optional(string)
    network_profile                           = optional(string)
    project                                   = optional(string)
    routing_mode                              = optional(string)
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
  description = "VPC settings. Name is supplied unchanged by the caller; custom subnet mode is the default."
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", var.network.name))
    error_message = "network.name must be a valid GCP resource name (1-63 lowercase letters/digits/hyphens)."
  }
  validation {
    condition     = var.network.routing_mode == null ? true : contains(["REGIONAL", "GLOBAL"], var.network.routing_mode)
    error_message = "routing_mode must be REGIONAL or GLOBAL."
  }
}

variable "subnetworks" {
  type = map(object({
    allow_subnet_cidr_routes_overlap = optional(bool)
    deletion_policy                  = optional(string)
    description                      = optional(string)
    external_ipv6_prefix             = optional(string)
    internal_ipv6_prefix             = optional(string)
    ip_cidr_range                    = optional(string)
    ip_collection                    = optional(string)
    ipv6_access_type                 = optional(string)
    name                             = string
    network                          = optional(string)
    private_ip_google_access         = optional(bool)
    private_ipv6_google_access       = optional(string)
    project                          = optional(string)
    purpose                          = optional(string)
    region                           = optional(string)
    reserved_internal_range          = optional(string)
    resolve_subnet_mask              = optional(string)
    role                             = optional(string)
    send_secondary_ip_range_if_empty = optional(bool)
    stack_type                       = optional(string)
    log_config = optional(object({
      aggregation_interval = optional(string)
      filter_expr          = optional(string)
      flow_sampling        = optional(number)
      metadata             = optional(string)
      metadata_fields      = optional(set(string))
    }))
    params = optional(object({
      resource_manager_tags = optional(map(string))
    }))
    secondary_ip_range = optional(map(object({
      ip_cidr_range           = optional(string)
      range_name              = string
      reserved_internal_range = optional(string)
    })), {})
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  nullable    = false
  description = "Subnets keyed by stable logical identifiers. Each entry has an explicit GCP name. Empty map creates no subnets."
  validation {
    condition     = alltrue([for subnet in values(var.subnetworks) : can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", subnet.name))])
    error_message = "Every subnet requires a valid GCP resource name."
  }
  validation {
    condition     = alltrue([for subnet in values(var.subnetworks) : subnet.ip_cidr_range == null ? true : can(cidrnetmask(subnet.ip_cidr_range))])
    error_message = "Provided subnet ip_cidr_range values must be valid IPv4 CIDRs."
  }
}
