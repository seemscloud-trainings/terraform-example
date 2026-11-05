locals {
  peer_region  = "europe-west1"
  secrets_file = "vpn.secrets.tfvars"
  tunnels = {
    primary = {
      interface       = 0
      interface_name  = "to-atlas-primary"
      ip_range        = "169.254.10.2/30"
      name            = "to-atlas-primary"
      peer_ip_address = "169.254.10.1"
      peer_name       = "to-atlas-primary"
    }
    secondary = {
      interface       = 1
      interface_name  = "to-atlas-secondary"
      ip_range        = "169.254.11.2/30"
      name            = "to-atlas-secondary"
      peer_ip_address = "169.254.11.1"
      peer_name       = "to-atlas-secondary"
    }
  }
}
