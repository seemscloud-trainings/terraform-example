variable "provider_config" {
  type = object({
    project                               = string
    region                                = optional(string)
    impersonate_service_account           = optional(string)
    impersonate_service_account_delegates = optional(list(string))
    billing_project                       = optional(string)
    user_project_override                 = optional(bool)
    default_labels                        = optional(map(string))
    request_timeout                       = optional(string)
    request_reason                        = optional(string)
    universe_domain                       = optional(string)
    compute_custom_endpoint               = optional(string)
  })
  nullable    = false
  description = "Provider defaults. Use ADC or impersonation; never commit credentials."
}
