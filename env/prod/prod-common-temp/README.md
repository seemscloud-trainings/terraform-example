# EU ↔ US HA VPN

Prepared configuration only. This change does not deploy resources.

| Side | Region | VPC | Subnet CIDR | Router ASN |
|---|---|---|---|---|
| EU | europe-west1 | vpn-eu-vpc | 10.80.0.0/24 | 65001 |
| US | us-east1 | vpn-us-vpc | 10.81.0.0/24 | 65002 |

Both VPCs belong to `prod-common-temp`. Names, ranges, ASNs and tunnel parameters
are in `vpn.hcl`. Each region contains the same five Terragrunt units:

- `network`: VPC and subnet, using `modules/network`.
- `router`: creates the local Cloud Router, using `modules/router`.
- `vpn-gateway`: creates the local HA gateway, using `modules/vpn-ha`.
- `tunnel`: creates two local endpoints, using the existing router and both HA gateways.
- `router-config`: creates interfaces and peers on the existing router, using
  `modules/router` with an empty routers map. It never manages router creation.

Dependency order is network → router/gateway → tunnels → router-config. Each
tunnel unit depends on both gateway units; neither gateway depends on tunnels.
There is no Terragrunt dependency cycle. The two routers are each owned by only
one state. Region-specific names keep the two global VPC names distinct.

There are two IPsec connections (four tunnel endpoint resources), with HA
interfaces 0 ↔ 0 and 1 ↔ 1. BGP uses 169.254.10.0/30 and 169.254.11.0/30, with EU
on .1 and US on .2. Gateway external IPs are allocated by GCP when gateways are
created. No pre-reserved public address or external VPN gateway is required.

## State and secrets

`root.hcl` uses the existing GCS bucket selected by `TF_STATE_BUCKET`; bucket
creation is disabled. Every unit has a separate prefix derived from its path.

From the repository root, copy `vpn.secrets.tfvars.example` to
`vpn.secrets.tfvars` and replace both sample PSKs with strong random secrets.
The resulting file is ignored by Git. Both regions use the same file, so each
pair of tunnel endpoints receives matching secrets. `VPN_SECRETS_FILE` can
instead specify an absolute path to another private tfvars file.

The `tunnel` units require that file for Terraform operations accepting variables.
They do not create or invent secret values. Standard-mode PSKs are stored in
Terraform state; protect access to the state bucket.

## Offline checks

From the repository root:

```sh
TF_STATE_BUCKET=validation-only-not-used TG_VALIDATE_ONLY=true terragrunt hcl validate
TF_STATE_BUCKET=validation-only-not-used TG_VALIDATE_ONLY=true \
  terragrunt --working-dir env/prod/prod-common-temp/europe-west1/tunnel render --format hcl
```

Validation mocks are allowed only for validate/render, never plan/apply/destroy.
Unset `TG_VALIDATE_ONLY` before real infrastructure operations. Initial real
planning requires outputs from prerequisite units; mocks must not be used as
real endpoint values.

Workload ingress firewall rules, test VMs and connectivity tests are intentionally
not defined here. BGP/IPsec setup does not itself allow application traffic through
VPC firewalls. These will be added separately if requested. Existing training
networks, VMs and application deployments are not part of these states.
