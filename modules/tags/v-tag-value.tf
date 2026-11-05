variable "values" {
  type = map(object({
    key             = optional(string)
    parent          = optional(string)
    short_name      = string
    description     = optional(string)
    deletion_policy = optional(string)
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default  = {}
  nullable = false
  validation {
    condition     = alltrue([for v in values(var.values) : (v.key != null) != (v.parent != null)])
    error_message = "Provide exactly one of key (managed key) or parent (existing key ID)."
  }
}
