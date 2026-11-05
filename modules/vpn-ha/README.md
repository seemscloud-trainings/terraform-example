# VPN HA

Creates HA VPN gateways and IPsec tunnels only. **No Cloud Router, interface,
BGP peer, VPC, firewall or static public address is created here.**

## Inputs and resources

- `provider_config`: default project/region and provider options.
- `gateways`: map of `google_compute_ha_vpn_gateway` configurations. Every name
  is explicit. Optional IPv4/IPv6 settings, labels, Interconnect interface
  attachments, resource tags, deletion policy and timeouts are supported.
- `tunnels`: map of `google_compute_vpn_tunnel` configurations. Every name is
  explicit. Choose `gateway_key` for a gateway created here or `vpn_gateway`
  for an existing HA gateway. Choose one peer: `peer_gateway_key`,
  `peer_gcp_gateway`, or `peer_external_gateway` plus its interface number.
  Router name/self-link is supplied by the caller. Interface numbers are 0/1.

Gateway project/region are inherited by local-key tunnels unless overridden.
The caller must keep explicit projects/regions compatible with the gateway and
router. Map keys identify instances; adding another tunnel does not renumber
existing tunnels. IKE version, traffic selectors, custom cipher suites, labels,
resource tags, deletion policy and timeouts remain configurable. Not every
combination is supported by GCP; HA dynamic routing restrictions still apply.

All HA-relevant configurable fields of Google provider 8.10.0 are exposed.
Synthetic SDK `id` and Classic-only `target_vpn_gateway`/`peer_ip` are not inputs.
The `id` field INSIDE gateway `vpn_interfaces` is supported; it identifies the
HA interface for Interconnect attachment configuration. Public gateway IPs are
computed by GCP, not configurable pre-reserved addresses. They remain assigned
for the lifetime of that gateway.

## PSKs

PSKs are separate sensitive maps, never part of tunnel iteration keys:

- `shared_secrets`: standard mode (default). Terraform stores these values in
  state; protect the backend. A tunnel selects `secret_key`, defaulting to its
  own map key. Both ends of a connection must select matching secret values.
- `write_only_shared_secrets`: sensitive, ephemeral map for
  `secret_mode = "write_only"`. Set `shared_secret_wo_version` and increment it
  when rotating. Supply the ephemeral value during both plan and apply when
  applying a saved plan. This requires Terraform >= 1.11.

No secret or secret hash is exported. Outputs `gateways` (including assigned
public interface IPs) and `tunnels` expose selected settings and are marked
sensitive to preserve caller sensitivity.

## Pair of GCP VPCs

[examples/gcp-to-gcp](examples/gcp-to-gcp) composes two router creations, two HA
gateways, four tunnel endpoints, four interfaces and four BGP peers. There are
two redundant IPsec connections: interface 0 ↔ 0 and 1 ↔ 1. The VPCs already
exist; their CIDRs must not overlap. Router ASNs differ. BGP link address pairs
must be valid and unused. Configure firewall rules for the desired workload
traffic separately; establishing IPsec does not grant application access.

The same router module is called a second time with existing router names and
empty `routers` to configure interfaces/BGP. This avoids a dependency cycle and
avoids two states managing the same router. In Terragrunt, use the same order:
router creation → VPN → router configuration. No new router-bgp module is needed.

Copy the sample tfvars and adapt projects, VPC references, names, ASNs and BGP
ranges. Supply PSKs in an ignored `local.secrets.tfvars` file, for example with
`-var-file=local.secrets.tfvars`. Never commit real keys. The module does not
connect to the existing `env/.../tunnel` placeholder automatically.

## Verification

Run module-local `terraform init -backend=false`, `terraform validate`, and
`terraform test`. Tests are mocked. For cross-module composition use:

```sh
python3 modules/vpn-ha/tests/verify_composition.py
```

Run that command from the repository root. It copies actual source into a
scratch directory, removes only child provider CONFIGURATIONS (keeping provider
requirements), and runs an inherited mock. A root mock does not replace concrete
provider blocks inside child modules. The example itself is therefore validated
but not used as a direct apply test. The test explicitly maps an aliased mock into every module. A loopback-only
Compute endpoint and invalid credentials additionally fail closed if a real
provider is accidentally instantiated.

No real HA VPN/BGP establishment is claimed by mock tests. Provider requirements
and configuration are in `provider.tf`; Terraform minimum is in `versions.tf`.
Because provider configuration is inside the module, do not place count,
for_each or depends_on on the module call; use the input maps.
