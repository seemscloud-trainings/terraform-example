locals {
  peer_region  = "us-east1"
  secrets_file = "vpn.secrets.tfvars"
  tunnels = {
    primary = {
      interface       = 0
      interface_name  = "to-orion-primary"
      ip_range        = "169.254.10.1/30"
      name            = "to-orion-primary"
      peer_ip_address = "169.254.10.2"
      peer_name       = "to-orion-primary"
    }
    secondary = {
      interface       = 1
      interface_name  = "to-orion-secondary"
      ip_range        = "169.254.11.1/30"
      name            = "to-orion-secondary"
      peer_ip_address = "169.254.11.2"
      peer_name       = "to-orion-secondary"
    }
  }
}
