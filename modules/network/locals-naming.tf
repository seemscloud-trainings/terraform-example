locals {
  naming = {
    network = var.network.name
    subnetworks = {
      for key, subnet in var.subnetworks : key => subnet.name
    }
  }
}
