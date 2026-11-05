resource "google_compute_vpn_tunnel" "this" {
  for_each                        = nonsensitive(toset(keys(var.tunnels)))
  deletion_policy                 = var.tunnels[each.key].deletion_policy
  description                     = var.tunnels[each.key].description
  ike_version                     = var.tunnels[each.key].ike_version
  labels                          = var.tunnels[each.key].labels
  local_traffic_selector          = var.tunnels[each.key].local_traffic_selector
  name                            = local.naming.tunnels[each.key]
  peer_external_gateway           = var.tunnels[each.key].peer_external_gateway
  peer_external_gateway_interface = var.tunnels[each.key].peer_external_gateway_interface
  peer_gcp_gateway                = var.tunnels[each.key].peer_gcp_gateway
  peer_ip                         = null
  project                         = local.tunnel_context[each.key].project
  region                          = local.tunnel_context[each.key].region
  remote_traffic_selector         = var.tunnels[each.key].remote_traffic_selector
  router                          = var.tunnels[each.key].router
  shared_secret                   = var.tunnels[each.key].secret_mode == "standard" ? lookup(var.shared_secrets, local.secret_keys[each.key], null) : null
  shared_secret_wo                = var.tunnels[each.key].secret_mode == "write_only" ? lookup(var.write_only_shared_secrets, local.secret_keys[each.key], null) : null
  shared_secret_wo_version        = var.tunnels[each.key].shared_secret_wo_version
  target_vpn_gateway              = null
  vpn_gateway                     = var.tunnels[each.key].vpn_gateway
  vpn_gateway_interface           = var.tunnels[each.key].vpn_gateway_interface
  dynamic "cipher_suite" {
    for_each = var.tunnels[each.key].cipher_suite == null ? [] : [var.tunnels[each.key].cipher_suite]
    iterator = item_cipher_suite
    content {
      dynamic "phase1" {
        for_each = item_cipher_suite.value.phase1 == null ? [] : [item_cipher_suite.value.phase1]
        iterator = item_phase1
        content {
          dh         = item_phase1.value.dh
          encryption = item_phase1.value.encryption
          integrity  = item_phase1.value.integrity
          prf        = item_phase1.value.prf
        }
      }
      dynamic "phase2" {
        for_each = item_cipher_suite.value.phase2 == null ? [] : [item_cipher_suite.value.phase2]
        iterator = item_phase2
        content {
          encryption = item_phase2.value.encryption
          integrity  = item_phase2.value.integrity
          pfs        = item_phase2.value.pfs
        }
      }
    }
  }
  dynamic "params" {
    for_each = var.tunnels[each.key].params == null ? [] : [var.tunnels[each.key].params]
    iterator = item_params
    content {
      resource_manager_tags = item_params.value.resource_manager_tags
    }
  }
  dynamic "timeouts" {
    for_each = var.tunnels[each.key].timeouts == null ? [] : [var.tunnels[each.key].timeouts]
    iterator = item_timeouts
    content {
      create = item_timeouts.value.create
      delete = item_timeouts.value.delete
      update = item_timeouts.value.update
    }
  }
}
