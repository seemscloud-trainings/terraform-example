# Network

Creates one GCP VPC and zero or more subnets. Follows the repository-local skill
[`AI/terraform-module/SKILL.md`](../../AI/terraform-module/SKILL.md).

## Interface

- `provider_config`: required object with `project`; optional default `region`,
  impersonation, billing, labels, timeout and endpoint settings. Authentication
  uses ADC or impersonation. No credential is stored in the module.
- `network`: required object with an explicit `name`. Custom subnet mode
  (`auto_create_subnetworks = false`) is the default. Other optional arguments
  preserve provider defaults unless set by the caller.
- `subnetworks`: `map(object(...))`, default `{}`. Every entry has an explicit
  `name`. The key is its stable Terraform identity, independent of the GCP name.
  Defaults to the VPC created here, its effective project, and the provider region.

All configurable fields of `google_compute_network` and
`google_compute_subnetwork` from `hashicorp/google` 8.10.0 are exposed, including
MTU, BGP/routing mode, IPv6, network profile, firewall-policy ordering, deletion
policy, resource-manager tags, purposes/roles, Private Google Access, reserved
internal ranges, flow logs and timeouts. Computed-only fields and the synthetic
SDK `id` are not inputs. Provider/API constraints still determine valid combinations.

`network.project` overrides the provider project. A subnet's `project`, `region`
and `network` can be explicitly overridden; an external network override means
that subnet intentionally does not belong to the VPC created by this module.

Secondary ranges are also keyed maps with explicit `range_name`. To remove all
secondary ranges, set `send_secondary_ip_range_if_empty = true`; otherwise the
provider preserves its documented default removal behavior. IPv4 CIDR is optional
in the input to allow provider-supported reserved-range/IPv6 configurations.

## Files and versions

- `versions.tf`: minimum Terraform 1.7 (including mocked testing support).
- `provider.tf`: pinned provider requirement and parameterized provider block.
- `v-network.tf`, `v-subnetwork.tf`, `v-provider.tf`: typed inputs and validation.
- `r-network.tf`, `r-subnetwork.tf`: resources named `this`.
- `locals-naming.tf`: names exactly as provided by the caller, without prefixes.
- `locals.tf`: effective project selection only.
- `outputs.tf`: `network` object and `subnetworks` map with IDs and useful attributes.

The provider is configured inside this module. Terraform therefore does not allow
`count`, `for_each` or `depends_on` on the calling module block. Multiple subnets
are supported through the `subnetworks` map instead.

## Example

See [`examples/basic/`](examples/basic/). `main.tf` passes variables, typed inputs
are in `variables.tf`, and values are in `terraform.tfvars.example`.

```hcl
subnetworks = {
  application = {
    name          = "training-application"
    ip_cidr_range = "10.10.1.0/24"
  }
  database = {
    name          = "training-database"
    ip_cidr_range = "10.10.2.0/24"
  }
}
```

Adding a `batch` key or reordering these entries does not change the Terraform
addresses of application/database. Renaming a key requires an explicit `moved`
block when preserving the existing resource. Changing an immutable provider
argument can still require replacement; using a map does not prevent that.

## Validation

Run from this directory:

```sh
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
terraform test
```

The tests use `mock_provider "google"` only. They verify defaults, explicit names,
network/project/region wiring, insertion/removal without changing other IDs,
advanced fields, secondary-range maps, false/zero values and invalid names/CIDRs.
Tested with Terraform 1.15.8 and Google provider 8.10.0. No real cloud resources
were deployed. The existing `env/.../tunnel` placeholder is not changed or connected
to this module.
