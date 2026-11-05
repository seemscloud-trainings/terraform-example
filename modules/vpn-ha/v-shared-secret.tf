variable "shared_secrets" {
  type        = map(string)
  default     = {}
  nullable    = false
  sensitive   = true
  description = "PSKs for standard mode. Keys are selected by tunnel secret_key (or tunnel map key). Standard PSKs are stored in Terraform state."
  validation {
    condition     = alltrue([for secret in values(var.shared_secrets) : length(secret) > 0])
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
    condition     = alltrue([for secret in values(var.write_only_shared_secrets) : length(secret) > 0])
    error_message = "PSKs must not be empty."
  }
  validation {
    condition = alltrue([for k, v in var.tunnels :
      v.secret_mode != "write_only" || contains(keys(var.write_only_shared_secrets), v.secret_key != null ? v.secret_key : k)
    ])
    error_message = "Every write_only tunnel needs an entry in write_only_shared_secrets."
  }
}
