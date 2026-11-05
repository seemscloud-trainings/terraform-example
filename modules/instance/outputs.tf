output "instance" {
  description = "Non-secret identity and addressing of the VM."
  value = {
    id             = google_compute_instance.this.id
    name           = google_compute_instance.this.name
    self_link      = google_compute_instance.this.self_link
    instance_id    = google_compute_instance.this.instance_id
    project        = google_compute_instance.this.project
    zone           = google_compute_instance.this.zone
    machine_type   = google_compute_instance.this.machine_type
    current_status = google_compute_instance.this.current_status
    network_interfaces = [

      for nic in google_compute_instance.this.network_interface : {
        name       = nic.name
        network    = nic.network
        subnetwork = nic.subnetwork
        network_ip = nic.network_ip
        public_ips = [
          for access in nic.access_config : access.nat_ip
        ]
      }

    ]
  }
}
