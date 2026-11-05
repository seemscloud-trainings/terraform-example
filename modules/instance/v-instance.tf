variable "instance" {
  type = object({
    allow_stopping_for_update  = optional(bool)
    can_ip_forward             = optional(bool)
    deletion_policy            = optional(string)
    deletion_protection        = optional(bool)
    description                = optional(string)
    desired_status             = optional(string)
    enable_display             = optional(bool)
    hostname                   = optional(string)
    key_revocation_action_type = optional(string)
    labels                     = optional(map(string))
    machine_type               = string
    metadata                   = optional(map(string))
    metadata_startup_script    = optional(string)
    min_cpu_platform           = optional(string)
    name                       = string
    project                    = optional(string)
    resource_policies          = optional(list(string))
    tags                       = optional(set(string))
    zone                       = optional(string)
    advanced_machine_features = optional(object({
      enable_nested_virtualization = optional(bool)
      enable_uefi_networking       = optional(bool)
      performance_monitoring_unit  = optional(string)
      threads_per_core             = optional(number)
      turbo_mode                   = optional(string)
      visible_core_count           = optional(number)
    }))
    attached_disk = optional(map(object({
      device_name                     = optional(string)
      disk_encryption_key_raw         = optional(string)
      disk_encryption_key_rsa         = optional(string)
      disk_encryption_service_account = optional(string)
      force_attach                    = optional(bool)
      kms_key_self_link               = optional(string)
      mode                            = optional(string)
      source                          = string
    })), {})
    boot_disk = object({
      auto_delete                     = optional(bool)
      device_name                     = optional(string)
      disk_encryption_key_raw         = optional(string)
      disk_encryption_key_rsa         = optional(string)
      disk_encryption_service_account = optional(string)
      force_attach                    = optional(bool)
      guest_os_features               = optional(list(string))
      interface                       = optional(string)
      kms_key_self_link               = optional(string)
      mode                            = optional(string)
      source                          = optional(string)
      initialize_params = optional(object({
        architecture                = optional(string)
        enable_confidential_compute = optional(bool)
        image                       = optional(string)
        labels                      = optional(map(string))
        provisioned_iops            = optional(number)
        provisioned_throughput      = optional(number)
        replica_zones               = optional(list(string))
        resource_manager_tags       = optional(map(string))
        resource_policies           = optional(list(string))
        size                        = optional(number)
        snapshot                    = optional(string)
        storage_pool                = optional(string)
        type                        = optional(string)
        source_image_encryption_key = optional(object({
          kms_key_self_link       = optional(string)
          kms_key_service_account = optional(string)
          raw_key                 = optional(string)
          rsa_encrypted_key       = optional(string)
        }))
        source_snapshot_encryption_key = optional(object({
          kms_key_self_link       = optional(string)
          kms_key_service_account = optional(string)
          raw_key                 = optional(string)
          rsa_encrypted_key       = optional(string)
        }))
      }))
    })
    confidential_instance_config = optional(object({
      confidential_instance_type  = optional(string)
      enable_confidential_compute = optional(bool)
    }))
    guest_accelerator = optional(map(object({
      count = number
      type  = string
    })), {})
    instance_encryption_key = optional(object({
      kms_key_self_link       = optional(string)
      kms_key_service_account = optional(string)
    }))
    network_interface = list(object({
      enable_vpc_scoped_dns       = optional(bool)
      igmp_query                  = optional(string)
      internal_ipv6_prefix_length = optional(number)
      ipv6_address                = optional(string)
      network                     = optional(string)
      network_attachment          = optional(string)
      network_ip                  = optional(string)
      nic_type                    = optional(string)
      queue_count                 = optional(number)
      service_class_id            = optional(string)
      stack_type                  = optional(string)
      subnetwork                  = optional(string)
      subnetwork_project          = optional(string)
      vlan                        = optional(number)
      access_config = optional(map(object({
        nat_ip                 = optional(string)
        network_tier           = optional(string)
        public_ptr_domain_name = optional(string)
      })), {})
      alias_ip_range = optional(map(object({
        ip_cidr_range         = string
        subnetwork_range_name = optional(string)
      })), {})
      ipv6_access_config = optional(map(object({
        external_ipv6               = optional(string)
        external_ipv6_prefix_length = optional(string)
        name                        = optional(string)
        network_tier                = string
        public_ptr_domain_name      = optional(string)
      })), {})
    }))
    network_performance_config = optional(object({
      total_egress_bandwidth_tier = string
    }))
    params = optional(object({
      resource_manager_tags = optional(map(string))
    }))
    reservation_affinity = optional(object({
      type = string
      specific_reservation = optional(object({
        key    = string
        values = list(string)
      }))
    }))
    scheduling = optional(object({
      automatic_restart           = optional(bool)
      availability_domain         = optional(number)
      host_error_timeout_seconds  = optional(number)
      instance_termination_action = optional(string)
      min_node_cpus               = optional(number)
      on_host_maintenance         = optional(string)
      preemptible                 = optional(bool)
      provisioning_model          = optional(string)
      termination_time            = optional(string)
      local_ssd_recovery_timeout = optional(object({
        nanos   = optional(number)
        seconds = number
      }))
      max_run_duration = optional(object({
        nanos   = optional(number)
        seconds = number
      }))
      node_affinities = optional(map(object({
        key      = string
        operator = string
        values   = set(string)
      })), {})
      on_instance_stop_action = optional(object({
        discard_local_ssd = optional(bool)
      }))
      preemption_notice_duration = optional(object({
        nanos   = optional(number)
        seconds = number
      }))
    }))
    scratch_disk = optional(map(object({
      device_name = optional(string)
      interface   = string
      size        = optional(number)
    })), {})
    service_account = optional(object({
      email  = optional(string)
      scopes = set(string)
    }))
    shielded_instance_config = optional(object({
      enable_integrity_monitoring = optional(bool)
      enable_secure_boot          = optional(bool)
      enable_vtpm                 = optional(bool)
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
    workload_identity_config = optional(object({
      identity                     = optional(string)
      identity_certificate_enabled = optional(bool)
    }))
  })
  nullable    = false
  description = "One VM. Repeated blocks use stable maps, except ordered network_interface entries defining nic0, nic1, etc. Disk encryption key inputs are sensitive and must not be committed."
  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", var.instance.name))
    error_message = "Instance name must be a valid GCP resource name."
  }
  validation {
    condition     = length(var.instance.network_interface) > 0
    error_message = "At least one network interface is required."
  }
  validation {
    condition     = var.instance.zone != null || var.zone != null
    error_message = "Set instance.zone or the module zone input."
  }
  validation {
    condition     = (var.instance.boot_disk.source != null) != (var.instance.boot_disk.initialize_params != null)
    error_message = "Boot disk requires exactly one of source or initialize_params."
  }
  validation {
    condition     = var.instance.metadata_startup_script == null || !contains(keys(coalesce(var.instance.metadata, {})), "startup-script")
    error_message = "Use metadata_startup_script or metadata startup-script, not both."
  }
}
