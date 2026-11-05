resource "google_compute_instance" "this" {
  allow_stopping_for_update  = var.instance.allow_stopping_for_update
  can_ip_forward             = var.instance.can_ip_forward
  deletion_policy            = var.instance.deletion_policy
  deletion_protection        = var.instance.deletion_protection
  description                = var.instance.description
  desired_status             = var.instance.desired_status
  enable_display             = var.instance.enable_display
  hostname                   = var.instance.hostname
  key_revocation_action_type = var.instance.key_revocation_action_type
  labels                     = var.instance.labels
  machine_type               = var.instance.machine_type
  metadata                   = var.instance.metadata
  metadata_startup_script    = var.instance.metadata_startup_script
  min_cpu_platform           = var.instance.min_cpu_platform
  name                       = local.naming.instance
  project                    = var.instance.project != null ? var.instance.project : var.project
  resource_policies          = var.instance.resource_policies
  tags                       = var.instance.tags
  zone                       = var.instance.zone != null ? var.instance.zone : var.zone
  dynamic "advanced_machine_features" {
    for_each = var.instance.advanced_machine_features == null ? [] : [
      var.instance.advanced_machine_features,
    ]
    iterator = item_advanced_machine_features
    content {
      enable_nested_virtualization = item_advanced_machine_features.value.enable_nested_virtualization
      enable_uefi_networking       = item_advanced_machine_features.value.enable_uefi_networking
      performance_monitoring_unit  = item_advanced_machine_features.value.performance_monitoring_unit
      threads_per_core             = item_advanced_machine_features.value.threads_per_core
      turbo_mode                   = item_advanced_machine_features.value.turbo_mode
      visible_core_count           = item_advanced_machine_features.value.visible_core_count
    }
  }
  dynamic "attached_disk" {
    for_each = nonsensitive(toset(keys(var.instance.attached_disk)))
    iterator = item_attached_disk
    content {
      device_name                     = var.instance.attached_disk[item_attached_disk.key].device_name
      disk_encryption_key_raw         = sensitive(var.instance.attached_disk[item_attached_disk.key].disk_encryption_key_raw)
      disk_encryption_key_rsa         = sensitive(var.instance.attached_disk[item_attached_disk.key].disk_encryption_key_rsa)
      disk_encryption_service_account = var.instance.attached_disk[item_attached_disk.key].disk_encryption_service_account
      force_attach                    = var.instance.attached_disk[item_attached_disk.key].force_attach
      kms_key_self_link               = var.instance.attached_disk[item_attached_disk.key].kms_key_self_link
      mode                            = var.instance.attached_disk[item_attached_disk.key].mode
      source                          = var.instance.attached_disk[item_attached_disk.key].source
    }
  }
  dynamic "boot_disk" {
    for_each = var.instance.boot_disk == null ? [] : [
      var.instance.boot_disk,
    ]
    iterator = item_boot_disk
    content {
      auto_delete                     = item_boot_disk.value.auto_delete
      device_name                     = item_boot_disk.value.device_name
      disk_encryption_key_raw         = sensitive(item_boot_disk.value.disk_encryption_key_raw)
      disk_encryption_key_rsa         = sensitive(item_boot_disk.value.disk_encryption_key_rsa)
      disk_encryption_service_account = item_boot_disk.value.disk_encryption_service_account
      force_attach                    = item_boot_disk.value.force_attach
      guest_os_features               = item_boot_disk.value.guest_os_features
      interface                       = item_boot_disk.value.interface
      kms_key_self_link               = item_boot_disk.value.kms_key_self_link
      mode                            = item_boot_disk.value.mode
      source                          = item_boot_disk.value.source
      dynamic "initialize_params" {
        for_each = item_boot_disk.value.initialize_params == null ? [] : [
          item_boot_disk.value.initialize_params,
        ]
        iterator = item_boot_disk_initialize_params
        content {
          architecture                = item_boot_disk_initialize_params.value.architecture
          enable_confidential_compute = item_boot_disk_initialize_params.value.enable_confidential_compute
          image                       = item_boot_disk_initialize_params.value.image
          labels                      = item_boot_disk_initialize_params.value.labels
          provisioned_iops            = item_boot_disk_initialize_params.value.provisioned_iops
          provisioned_throughput      = item_boot_disk_initialize_params.value.provisioned_throughput
          replica_zones               = item_boot_disk_initialize_params.value.replica_zones
          resource_manager_tags       = item_boot_disk_initialize_params.value.resource_manager_tags
          resource_policies           = item_boot_disk_initialize_params.value.resource_policies
          size                        = item_boot_disk_initialize_params.value.size
          snapshot                    = item_boot_disk_initialize_params.value.snapshot
          storage_pool                = item_boot_disk_initialize_params.value.storage_pool
          type                        = item_boot_disk_initialize_params.value.type
          dynamic "source_image_encryption_key" {
            for_each = item_boot_disk_initialize_params.value.source_image_encryption_key == null ? [] : [
              item_boot_disk_initialize_params.value.source_image_encryption_key,
            ]
            iterator = item_boot_disk_initialize_params_source_image_encryption_key
            content {
              kms_key_self_link       = item_boot_disk_initialize_params_source_image_encryption_key.value.kms_key_self_link
              kms_key_service_account = item_boot_disk_initialize_params_source_image_encryption_key.value.kms_key_service_account
              raw_key                 = sensitive(item_boot_disk_initialize_params_source_image_encryption_key.value.raw_key)
              rsa_encrypted_key       = sensitive(item_boot_disk_initialize_params_source_image_encryption_key.value.rsa_encrypted_key)
            }
          }
          dynamic "source_snapshot_encryption_key" {
            for_each = item_boot_disk_initialize_params.value.source_snapshot_encryption_key == null ? [] : [
              item_boot_disk_initialize_params.value.source_snapshot_encryption_key,
            ]
            iterator = item_boot_disk_initialize_params_source_snapshot_encryption_key
            content {
              kms_key_self_link       = item_boot_disk_initialize_params_source_snapshot_encryption_key.value.kms_key_self_link
              kms_key_service_account = item_boot_disk_initialize_params_source_snapshot_encryption_key.value.kms_key_service_account
              raw_key                 = sensitive(item_boot_disk_initialize_params_source_snapshot_encryption_key.value.raw_key)
              rsa_encrypted_key       = sensitive(item_boot_disk_initialize_params_source_snapshot_encryption_key.value.rsa_encrypted_key)
            }
          }
        }
      }
    }
  }
  dynamic "confidential_instance_config" {
    for_each = var.instance.confidential_instance_config == null ? [] : [
      var.instance.confidential_instance_config,
    ]
    iterator = item_confidential_instance_config
    content {
      confidential_instance_type  = item_confidential_instance_config.value.confidential_instance_type
      enable_confidential_compute = item_confidential_instance_config.value.enable_confidential_compute
    }
  }
  dynamic "guest_accelerator" {
    for_each = nonsensitive(toset(keys(var.instance.guest_accelerator)))
    iterator = item_guest_accelerator
    content {
      count = var.instance.guest_accelerator[item_guest_accelerator.key].count
      type  = var.instance.guest_accelerator[item_guest_accelerator.key].type
    }
  }
  dynamic "instance_encryption_key" {
    for_each = var.instance.instance_encryption_key == null ? [] : [
      var.instance.instance_encryption_key,
    ]
    iterator = item_instance_encryption_key
    content {
      kms_key_self_link       = item_instance_encryption_key.value.kms_key_self_link
      kms_key_service_account = item_instance_encryption_key.value.kms_key_service_account
    }
  }
  dynamic "network_interface" {
    for_each = var.instance.network_interface
    iterator = item_network_interface
    content {
      enable_vpc_scoped_dns       = item_network_interface.value.enable_vpc_scoped_dns
      igmp_query                  = item_network_interface.value.igmp_query
      internal_ipv6_prefix_length = item_network_interface.value.internal_ipv6_prefix_length
      ipv6_address                = item_network_interface.value.ipv6_address
      network                     = item_network_interface.value.network
      network_attachment          = item_network_interface.value.network_attachment
      network_ip                  = item_network_interface.value.network_ip
      nic_type                    = item_network_interface.value.nic_type
      queue_count                 = item_network_interface.value.queue_count
      service_class_id            = item_network_interface.value.service_class_id
      stack_type                  = item_network_interface.value.stack_type
      subnetwork                  = item_network_interface.value.subnetwork
      subnetwork_project          = item_network_interface.value.subnetwork_project
      vlan                        = item_network_interface.value.vlan
      dynamic "access_config" {
        for_each = nonsensitive(toset(keys(item_network_interface.value.access_config)))
        iterator = item_network_interface_access_config
        content {
          nat_ip                 = item_network_interface.value.access_config[item_network_interface_access_config.key].nat_ip
          network_tier           = item_network_interface.value.access_config[item_network_interface_access_config.key].network_tier
          public_ptr_domain_name = item_network_interface.value.access_config[item_network_interface_access_config.key].public_ptr_domain_name
        }
      }
      dynamic "alias_ip_range" {
        for_each = nonsensitive(toset(keys(item_network_interface.value.alias_ip_range)))
        iterator = item_network_interface_alias_ip_range
        content {
          ip_cidr_range         = item_network_interface.value.alias_ip_range[item_network_interface_alias_ip_range.key].ip_cidr_range
          subnetwork_range_name = item_network_interface.value.alias_ip_range[item_network_interface_alias_ip_range.key].subnetwork_range_name
        }
      }
      dynamic "ipv6_access_config" {
        for_each = nonsensitive(toset(keys(item_network_interface.value.ipv6_access_config)))
        iterator = item_network_interface_ipv6_access_config
        content {
          external_ipv6               = item_network_interface.value.ipv6_access_config[item_network_interface_ipv6_access_config.key].external_ipv6
          external_ipv6_prefix_length = item_network_interface.value.ipv6_access_config[item_network_interface_ipv6_access_config.key].external_ipv6_prefix_length
          name                        = item_network_interface.value.ipv6_access_config[item_network_interface_ipv6_access_config.key].name
          network_tier                = item_network_interface.value.ipv6_access_config[item_network_interface_ipv6_access_config.key].network_tier
          public_ptr_domain_name      = item_network_interface.value.ipv6_access_config[item_network_interface_ipv6_access_config.key].public_ptr_domain_name
        }
      }
    }
  }
  dynamic "network_performance_config" {
    for_each = var.instance.network_performance_config == null ? [] : [
      var.instance.network_performance_config,
    ]
    iterator = item_network_performance_config
    content {
      total_egress_bandwidth_tier = item_network_performance_config.value.total_egress_bandwidth_tier
    }
  }
  dynamic "params" {
    for_each = var.instance.params == null ? [] : [
      var.instance.params,
    ]
    iterator = item_params
    content {
      resource_manager_tags = item_params.value.resource_manager_tags
    }
  }
  dynamic "reservation_affinity" {
    for_each = var.instance.reservation_affinity == null ? [] : [
      var.instance.reservation_affinity,
    ]
    iterator = item_reservation_affinity
    content {
      type = item_reservation_affinity.value.type
      dynamic "specific_reservation" {
        for_each = item_reservation_affinity.value.specific_reservation == null ? [] : [
          item_reservation_affinity.value.specific_reservation,
        ]
        iterator = item_reservation_affinity_specific_reservation
        content {
          key    = item_reservation_affinity_specific_reservation.value.key
          values = item_reservation_affinity_specific_reservation.value.values
        }
      }
    }
  }
  dynamic "scheduling" {
    for_each = var.instance.scheduling == null ? [] : [
      var.instance.scheduling,
    ]
    iterator = item_scheduling
    content {
      automatic_restart           = item_scheduling.value.automatic_restart
      availability_domain         = item_scheduling.value.availability_domain
      host_error_timeout_seconds  = item_scheduling.value.host_error_timeout_seconds
      instance_termination_action = item_scheduling.value.instance_termination_action
      min_node_cpus               = item_scheduling.value.min_node_cpus
      on_host_maintenance         = item_scheduling.value.on_host_maintenance
      preemptible                 = item_scheduling.value.preemptible
      provisioning_model          = item_scheduling.value.provisioning_model
      termination_time            = item_scheduling.value.termination_time
      dynamic "local_ssd_recovery_timeout" {
        for_each = item_scheduling.value.local_ssd_recovery_timeout == null ? [] : [
          item_scheduling.value.local_ssd_recovery_timeout,
        ]
        iterator = item_scheduling_local_ssd_recovery_timeout
        content {
          nanos   = item_scheduling_local_ssd_recovery_timeout.value.nanos
          seconds = item_scheduling_local_ssd_recovery_timeout.value.seconds
        }
      }
      dynamic "max_run_duration" {
        for_each = item_scheduling.value.max_run_duration == null ? [] : [
          item_scheduling.value.max_run_duration,
        ]
        iterator = item_scheduling_max_run_duration
        content {
          nanos   = item_scheduling_max_run_duration.value.nanos
          seconds = item_scheduling_max_run_duration.value.seconds
        }
      }
      dynamic "node_affinities" {
        for_each = nonsensitive(toset(keys(item_scheduling.value.node_affinities)))
        iterator = item_scheduling_node_affinities
        content {
          key      = item_scheduling.value.node_affinities[item_scheduling_node_affinities.key].key
          operator = item_scheduling.value.node_affinities[item_scheduling_node_affinities.key].operator
          values   = item_scheduling.value.node_affinities[item_scheduling_node_affinities.key].values
        }
      }
      dynamic "on_instance_stop_action" {
        for_each = item_scheduling.value.on_instance_stop_action == null ? [] : [
          item_scheduling.value.on_instance_stop_action,
        ]
        iterator = item_scheduling_on_instance_stop_action
        content {
          discard_local_ssd = item_scheduling_on_instance_stop_action.value.discard_local_ssd
        }
      }
      dynamic "preemption_notice_duration" {
        for_each = item_scheduling.value.preemption_notice_duration == null ? [] : [
          item_scheduling.value.preemption_notice_duration,
        ]
        iterator = item_scheduling_preemption_notice_duration
        content {
          nanos   = item_scheduling_preemption_notice_duration.value.nanos
          seconds = item_scheduling_preemption_notice_duration.value.seconds
        }
      }
    }
  }
  dynamic "scratch_disk" {
    for_each = nonsensitive(toset(keys(var.instance.scratch_disk)))
    iterator = item_scratch_disk
    content {
      device_name = var.instance.scratch_disk[item_scratch_disk.key].device_name
      interface   = var.instance.scratch_disk[item_scratch_disk.key].interface
      size        = var.instance.scratch_disk[item_scratch_disk.key].size
    }
  }
  dynamic "service_account" {
    for_each = var.instance.service_account == null ? [] : [
      var.instance.service_account,
    ]
    iterator = item_service_account
    content {
      email  = item_service_account.value.email
      scopes = item_service_account.value.scopes
    }
  }
  dynamic "shielded_instance_config" {
    for_each = var.instance.shielded_instance_config == null ? [] : [
      var.instance.shielded_instance_config,
    ]
    iterator = item_shielded_instance_config
    content {
      enable_integrity_monitoring = item_shielded_instance_config.value.enable_integrity_monitoring
      enable_secure_boot          = item_shielded_instance_config.value.enable_secure_boot
      enable_vtpm                 = item_shielded_instance_config.value.enable_vtpm
    }
  }
  dynamic "timeouts" {
    for_each = var.instance.timeouts == null ? [] : [
      var.instance.timeouts,
    ]
    iterator = item_timeouts
    content {
      create = item_timeouts.value.create
      delete = item_timeouts.value.delete
      update = item_timeouts.value.update
    }
  }
  dynamic "workload_identity_config" {
    for_each = var.instance.workload_identity_config == null ? [] : [
      var.instance.workload_identity_config,
    ]
    iterator = item_workload_identity_config
    content {
      identity                     = item_workload_identity_config.value.identity
      identity_certificate_enabled = item_workload_identity_config.value.identity_certificate_enabled
    }
  }
}
