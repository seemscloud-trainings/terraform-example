output "subnetworks" {
  description = "Created subnets, preserving the caller's stable map keys."
  value = {
    for key, subnet in google_compute_subnetwork.this : key => {
      id                 = subnet.id
      name               = subnet.name
      self_link          = subnet.self_link
      project            = subnet.project
      region             = subnet.region
      network            = subnet.network
      ip_cidr_range      = subnet.ip_cidr_range
      gateway_address    = subnet.gateway_address
      stack_type         = subnet.stack_type
      subnetwork_id      = subnet.subnetwork_id
      secondary_ip_range = subnet.secondary_ip_range
    }
  }
}
