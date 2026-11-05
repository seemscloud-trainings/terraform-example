# Regional networking and HA VPN connections

Prepared configuration only; editing these files does not deploy resources.

| Site | Region | VPC | Subnet | ASN |
|---|---|---|---|---|
| EU | europe-west1 | vpn-eu-vpc | 10.80.0.0/24 | 65001 |
| US | us-east1 | vpn-us-vpc | 10.81.0.0/24 | 65002 |

Each region owns one shared network, router and gateway. Connections are named
by their peer, rather than assuming that the region has only one peer:

```text
europe-west1/
├── region.hcl
└── networking/
    ├── networking.hcl
    ├── network/
    ├── router/
    ├── vpn-gateway/
    └── connections/
        └── to-us-east1/
            ├── connection.hcl
            ├── tunnels/
            └── bgp/
```

`us-east1` has the reciprocal `connections/to-europe-west1/` directory.
`networking/networking.hcl` contains only that regional site's names, CIDR and
ASN. Each `connection.hcl` contains only that local connection endpoint: peer
region, secret-file location and tunnel/BGP parameters. There is no project-level
VPN inventory. BGP reads the peer ASN from the peer's regional networking.hcl.

## Ownership and dependencies

- `network` uses the network module to own the regional site's VPC and subnet.
  GCP VPCs themselves are global resources; the region directory groups this site.
- `router` owns the site's Cloud Router.
- `vpn-gateway` owns the site's HA gateway.
- Each connection's `tunnels` owns only that endpoint's two VPN tunnels and
  depends on the local router and the local/peer gateway.
- Each connection's `bgp` uses the router module with no routers map. It owns
  only that connection's interfaces and BGP peers on the shared local router.

The graph is network → router/gateway → connection tunnels → connection BGP.
Gateways never depend on connections, so adding a peer does not introduce a
cycle or duplicate ownership of routers. Resource names must be unique within
their GCP scope, including interface/peer names across connections on one router.

## Add another connection

1. For a new region, add its `region.hcl`, `networking/networking.hcl` and the
   three shared units (network, router, vpn-gateway). Give the site a distinct VPC
   name, non-overlapping subnet CIDR and appropriate ASN. Reuse existing regional
   units when they already exist.
2. Add `connections/to-<peer-region>/` in both endpoint regions. The `tunnels`
   and `bgp` unit files are generic; connection.hcl supplies the local parameters.
3. Set `peer_region`, a matching `secrets_file` and the local tunnel map in each
   connection.hcl. Names must be unique in their GCP scope. Use two unused BGP
   /30 networks, reciprocal local/peer addresses and interface pairs 0 ↔ 0, 1 ↔ 1.
4. Supply a separate ignored secrets file for the connection, e.g.
   `eu-asia.secrets.tfvars`, with matching primary/secondary PSKs for both ends.
   Do not duplicate the local router/gateway, and do not create a full mesh unless
   that topology is requested.

## State and secrets

`root.hcl` uses the existing bucket selected by `TF_STATE_BUCKET` and does not
create it. Every connection/unit has a separate state prefix. An explicit map
preserves the four original EU-US tunnel/BGP state locations after the folder
move. New connections use their own path-derived state keys; never add them to
those legacy aliases or point multiple units at the same state.

The existing `eu-us` connection still uses `vpn.secrets.tfvars` at repository
root. Copy `vpn.secrets.tfvars.example` there and replace both placeholders.
`*.secrets.tfvars` is ignored by Git. Standard PSKs are stored in Terraform state,
so access to the state backend must be protected.

`connection.hcl` → `locals.secrets_file` is relative to repository root. Optional
`VPN_SECRETS_FILE` overrides the path for a particular invocation; avoid setting
that globally when running several connections that use different PSK files.

## Validation

```sh
terragrunt hcl fmt --check
```

All environment references use real dependency outputs. No mock outputs,
output-skipping switches, or constructed Google API resource links exist in
these units. Full rendering/planning requires the prerequisite units to have
real state outputs; do not substitute example values for those outputs.

Static checks cover HCL formatting and dependency paths. The dependency graph
and state mapping are unchanged by removing the validation mocks. Existing
EU-US resource inputs still reference the same dependencies and output fields.

Workload firewall rules and test VMs are not defined here. IPsec/BGP establishment
does not itself permit workload traffic through VPC firewalls. Existing training
networks and application deployments are outside these states.
