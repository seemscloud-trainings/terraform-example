locals {
  interfaces_context = {
    for k, v in var.interfaces : k => {
      router  = v.router_key != null ? google_compute_router.this[v.router_key].name : v.router
      project = v.project != null ? v.project : (v.router_key != null ? google_compute_router.this[v.router_key].project : var.project)
      region  = v.region != null ? v.region : (v.router_key != null ? google_compute_router.this[v.router_key].region : var.region)
    }
  }
  peers_context = {
    for k, v in var.peers : k => {
      router  = v.router_key != null ? google_compute_router.this[v.router_key].name : v.router
      project = v.project != null ? v.project : (v.router_key != null ? google_compute_router.this[v.router_key].project : var.project)
      region  = v.region != null ? v.region : (v.router_key != null ? google_compute_router.this[v.router_key].region : var.region)
    }
  }
}
