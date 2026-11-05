# Router

Reusable GCP Cloud Router module. It does not create VPN gateways/tunnels, NAT,
VPCs, Interconnect attachments or router appliances. Follow the repository-local
[Terraform module skill](../../AI/terraform-module/SKILL.md).

## Inputs

- `provider_config`: default project/region and provider configuration; same
  contract as `modules/network`. Credentials come from ADC or impersonation.
- `routers`: map of router objects with explicit names. Empty by default.
  BGP is optional, so a router can be created for a separate Cloud NAT module.
- `interfaces`: map of interfaces. Choose `router_key` for a router created here,
  or `router` for an existing router's **name**. Supports VPN tunnel references,
  Interconnect attachments and appliance interface settings.
- `peers`: map of BGP peers. Choose `router_key` or `router`; choose `interface_key`
  for a local interface or `interface` for an existing interface's name.

`project` and `region` overrides take precedence; otherwise interface/peer
settings inherit the locally selected router, then provider defaults. A peer
using `interface_key` must select the same router/project/region as its interface.
Existing router names and attachment/tunnel references are passed unchanged.

All configurable arguments/blocks of `google_compute_router`,
`google_compute_router_interface` and `google_compute_router_peer` in Google
8.10.0 are supported, except synthetic SDK `id`. This includes advertisement
maps, priorities including zero flags, IPv4/IPv6, custom learned routes, BFD,
MD5, import/export policy references, resource-manager tags, deletion policy and
timeouts. BFD and other settings remain subject to GCP support for the chosen
connection type. Route policy objects and NAT are separately owned resources.

Names are supplied by the user and only referenced in `locals-naming.tf`.
Resource map keys are stable Terraform identities. Reordering/adding another
key does not renumber existing instances. Immutable argument changes or key
renames may still require replacement or explicit moved blocks.

## Use with and without VPN

For a standalone router, set only `routers`; interfaces and peers remain empty.
See [examples/basic](examples/basic).

For an already-created router, leave `routers = {}` and supply its name, project
and region in `interfaces`/`peers`. This mode creates no router and never adopts
another stack's router into its state. `redundant_interface` and externally
managed route policies must already exist, or be provisioned by an earlier
module invocation. Do not claim provider/GCP-generated interfaces or peers.

For HA VPN, the dependency order is:

1. Router creation (`routers` map, no interfaces/peers).
2. `vpn-ha` receives router IDs and creates gateways/tunnels.
3. Another invocation of this SAME `router` module uses existing router names
   and tunnel IDs to create interfaces/peers, with `routers = {}`.

There is no separate router-bgp module. This also permits three acyclic
Terragrunt units. The full Terraform composition is in
[the VPN example](../vpn-ha/examples/gcp-to-gcp).

## Outputs and verification

Outputs `routers`, `interfaces`, `peers` preserve map keys and expose selected
identifiers/settings, never authentication secrets. They are marked sensitive
because caller input sensitivity can propagate through names and references.

Provider requirements/configuration are in `provider.tf`, minimum Terraform
1.11 is in `versions.tf`. Internal provider configuration means callers must not
use count/for_each/depends_on on the module block; use the resource maps.

`terraform init -backend=false`, `terraform validate`, `terraform test` verify
this module. Tests use mock_provider; they do not prove live BGP reachability.
Never run a real apply merely to validate a module.
