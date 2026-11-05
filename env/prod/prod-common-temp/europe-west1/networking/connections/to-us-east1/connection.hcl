locals {
  peer_region  = "us-east1"
  secrets_file = "vpn.secrets.tfvars"
  tunnels = {
    primary = {
      interface       = 0
      interface_name  = "vpn-eu-primary-if"
      ip_range        = "169.254.10.1/30"
      name            = "vpn-eu-primary"
      peer_ip_address = "169.254.10.2"
      peer_name       = "vpn-eu-primary-peer"
    }
    secondary = {
      interface       = 1
      interface_name  = "vpn-eu-secondary-if"
      ip_range        = "169.254.11.1/30"
      name            = "vpn-eu-secondary"
      peer_ip_address = "169.254.11.2"
      peer_name       = "vpn-eu-secondary-peer"
    }
  }
}
