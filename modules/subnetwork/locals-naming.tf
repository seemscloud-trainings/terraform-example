locals {
  naming = {
    subnetworks = {
      for key, subnet in var.subnetworks : key => subnet.name
    }
  }
}
