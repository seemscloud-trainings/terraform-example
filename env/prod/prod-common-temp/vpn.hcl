locals {
  sites = {
    europe-west1 = {
      peer_region  = "us-east1"
      network_name = "vpn-eu-vpc"
      subnet_name  = "vpn-eu-subnet"
      cidr         = "10.80.0.0/24"
      router_name  = "vpn-eu-router"
      gateway_name = "vpn-eu-gateway"
      asn          = 65001
      tunnels = {
        primary = {
          name      = "vpn-eu-primary", interface_name = "vpn-eu-primary-if", peer_name = "vpn-eu-primary-peer"
          interface = 0, ip_range = "169.254.10.1/30", peer_ip_address = "169.254.10.2"
        }
        secondary = {
          name      = "vpn-eu-secondary", interface_name = "vpn-eu-secondary-if", peer_name = "vpn-eu-secondary-peer"
          interface = 1, ip_range = "169.254.11.1/30", peer_ip_address = "169.254.11.2"
        }
      }
    }
    us-east1 = {
      peer_region  = "europe-west1"
      network_name = "vpn-us-vpc"
      subnet_name  = "vpn-us-subnet"
      cidr         = "10.81.0.0/24"
      router_name  = "vpn-us-router"
      gateway_name = "vpn-us-gateway"
      asn          = 65002
      tunnels = {
        primary = {
          name      = "vpn-us-primary", interface_name = "vpn-us-primary-if", peer_name = "vpn-us-primary-peer"
          interface = 0, ip_range = "169.254.10.2/30", peer_ip_address = "169.254.10.1"
        }
        secondary = {
          name      = "vpn-us-secondary", interface_name = "vpn-us-secondary-if", peer_name = "vpn-us-secondary-peer"
          interface = 1, ip_range = "169.254.11.2/30", peer_ip_address = "169.254.11.1"
        }
      }
    }
  }
}
