variable "hub" {
  type = object({
    deletion_policy = optional(string)
    description     = optional(string)
    export_psc      = optional(bool)
    labels          = optional(map(string))
    name            = string
    policy_mode     = optional(string)
    preset_topology = optional(string)
    project         = optional(string)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
  })
  nullable = false
}
