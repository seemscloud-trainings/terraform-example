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
