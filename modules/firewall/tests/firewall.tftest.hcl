mock_provider "google" {}

variables {
  project = "test-project"
  firewall = {
    name          = "amber"
    network       = "projects/test-project/global/networks/atlas"
    direction     = "INGRESS"
    source_ranges = ["0.0.0.0/0"]
    target_tags   = ["ssh"]
    allow = {
      ssh = {
        protocol = "tcp"
        ports    = ["22"]
      }
    }
  }
}

run "ssh_scope" {
  command = plan
  assert {
    condition     = google_compute_firewall.this.target_tags == toset(["ssh"]) && one(google_compute_firewall.this.allow).ports == tolist(["22"]) && google_compute_firewall.this.source_ranges == toset(["0.0.0.0/0"])
    error_message = "Only SSH-tagged instances should receive TCP 22 from the internet."
  }
}

run "conflicting_actions" {
  command = plan
  variables {
    firewall = {
      name    = "amber"
      network = "existing"
      allow = {
        ssh = {
          protocol = "tcp"
        }
      }
      deny = {
        ssh = {
          protocol = "tcp"
        }
      }
    }
  }
  expect_failures = [var.firewall]
}
