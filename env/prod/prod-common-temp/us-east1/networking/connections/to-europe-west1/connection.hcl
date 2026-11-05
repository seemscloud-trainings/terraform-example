locals {
  peer_region  = "europe-west1"
  secrets_file = "vpn.secrets.tfvars"
  tunnels = {
    primary = {
      interface       = 0
      interface_name  = "vpn-us-primary-if"
      ip_range        = "169.254.10.2/30"
      name            = "vpn-us-primary"
      peer_ip_address = "169.254.10.1"
      peer_name       = "vpn-us-primary-peer"
    }
    secondary = {
      interface       = 1
      interface_name  = "vpn-us-secondary-if"
      ip_range        = "169.254.11.2/30"
      name            = "vpn-us-secondary"
      peer_ip_address = "169.254.11.1"
      peer_name       = "vpn-us-secondary-peer"
    }
  }
}
