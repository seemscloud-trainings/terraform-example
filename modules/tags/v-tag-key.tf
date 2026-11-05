variable "keys" {
  type = map(object({
    parent               = string
    short_name           = string
    description          = optional(string)
    deletion_policy      = optional(string)
    allowed_values_regex = optional(string)
    purpose              = optional(string)
    purpose_data         = optional(map(string))
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default  = {}
  nullable = false
}
