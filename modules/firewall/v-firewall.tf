variable "firewall" {
  type = object({
    deletion_policy         = optional(string)
    description             = optional(string)
    destination_ranges      = optional(set(string))
    direction               = optional(string)
    disabled                = optional(bool)
    enable_logging          = optional(bool)
    name                    = string
    network                 = string
    priority                = optional(number)
    project                 = optional(string)
    source_ranges           = optional(set(string))
    source_service_accounts = optional(set(string))
    source_tags             = optional(set(string))
    target_service_accounts = optional(set(string))
    target_tags             = optional(set(string))
    allow = optional(map(object({
      ports    = optional(list(string))
      protocol = string
    })), {})
    deny = optional(map(object({
      ports    = optional(list(string))
      protocol = string
    })), {})
    log_config = optional(object({
      metadata = string
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
  nullable = false
  validation {
    condition     = (length(var.firewall.allow) > 0) != (length(var.firewall.deny) > 0)
    error_message = "Specify allow rules or deny rules, never both."
  }
}
