locals {
  sites = {
    europe-west1 = {
      asn          = 65001
      cidr         = "10.80.0.0/24"
      gateway_name = "vpn-eu-gateway"
      network_name = "vpn-eu-vpc"
      router_name  = "vpn-eu-router"
      subnet_name  = "vpn-eu-subnet"
    }
    us-east1 = {
      asn          = 65002
      cidr         = "10.81.0.0/24"
      gateway_name = "vpn-us-gateway"
      network_name = "vpn-us-vpc"
      router_name  = "vpn-us-router"
      subnet_name  = "vpn-us-subnet"
    }
  }
  connections = {
    eu-us = {
      secrets_file = "vpn.secrets.tfvars"
      endpoints = {
        europe-west1 = {
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
        us-east1 = {
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
      }
    }
  }
}
