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
`connection.hcl` selects an entry from `locals.connections` in `vpn.hcl`.
`locals.sites` holds shared regional properties. Each connection contains its
own two endpoints, tunnel names, BGP addresses and secret-file location.

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

1. Add a site to `vpn.hcl` only if the region does not exist yet. Give it a
   non-overlapping subnet range and suitable ASN, and create its `region.hcl`
   plus the three shared networking units. Reuse existing regional units.
2. Add a named connection, e.g. `eu-asia`, to `locals.connections`, with exactly
   two regional endpoints. Give it explicit unique tunnel/interface/peer names,
   two unused BGP /30 networks and reciprocal local/peer IPs. Interface pairs
   remain 0 ↔ 0 and 1 ↔ 1.
3. In both endpoint regions add `connections/to-<peer-region>/`. Copy the generic
   `tunnels` and `bgp` unit files and set the connection key in `connection.hcl`.
   Their paths, peer selection and inputs are derived from context; no module
   modification or duplicate regional router/gateway is needed.
4. Point that connection at its own ignored secrets file, e.g.
   `eu-asia.secrets.tfvars`. It must contain matching `primary`/`secondary` PSKs
   for the two endpoints. Decide which region pairs should connect; adding a
   region does not silently create a full mesh.

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

`connections.<key>.secrets_file` is relative to repository root. Optional
`VPN_SECRETS_FILE` overrides the path for a particular invocation; avoid setting
that globally when running several connections that use different PSK files.

## Validation

```sh
TF_STATE_BUCKET=validation-only-not-used TG_VALIDATE_ONLY=true terragrunt hcl validate
TF_STATE_BUCKET=validation-only-not-used TG_VALIDATE_ONLY=true \
  terragrunt --working-dir env/prod/prod-common-temp/europe-west1/networking/connections/to-us-east1/tunnels render --format hcl
```

Mocks are allowed for validate/render only, not plan/apply/destroy. Unset
`TG_VALIDATE_ONLY` before infrastructure operations. Initial real planning needs
outputs from the prerequisite units.

Verified: existing EU-US inputs, state prefixes and secret-file paths are
unchanged; all ten dependencies resolve without cycles. An isolated three-site,
two-connection scenario has seventeen units with distinct state prefixes and
shared regional infrastructure. That extra site was not added to this environment.

Workload firewall rules and test VMs are not defined here. IPsec/BGP establishment
does not itself permit workload traffic through VPC firewalls. Existing training
networks and application deployments are outside these states.
