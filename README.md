# terraform-castai-omni-edge-location-gcp

Terraform module for creating CAST AI edge locations in Google Cloud Platform (GCP).

This module automates the provisioning of GCP infrastructure required for CAST AI edge locations, including:
- Service account with necessary IAM roles
- VPC network and subnet
- Firewall rules for edge location connectivity
- CAST AI edge location registration

## Breaking changes in v2

v2 is not backwards compatible with v1. Upgrading requires destroying the v1 edge location and creating a new one with v2.

Both versions can run simultaneously. During migration, create counterpart v2 edge locations first, then remove v1 once they are no longer in use.

**Note: creating new v1 edge locations will no longer be supported.**

### Running v1 and v2 simultaneously

Pin existing edge locations to v1 while creating new ones with v2:

```hcl
# Keep existing edge location on v1
module "castai_gcp_edge_location_existing" {
  source  = "castai/omni-edge-location-gcp/castai"
  version = "~> 1.0"

  cluster_id      = var.cluster_id
  organization_id = var.organization_id
  region          = "europe-west4"
}

# New edge location on v2
module "castai_gcp_edge_location_new" {
  source = "castai/omni-edge-location-gcp/castai"
  version = "~> 2.0"

  cluster_id      = var.cluster_id
  organization_id = var.organization_id
  region          = "europe-west4"
}
```


## Usage

> **Warning**
> This module expects the cluster to be onboarded to CAST AI with OMNI enabled.

> **Note:** The GCP provider must be configured with the target project before using this module.

```hcl
provider "google" {
  project = "my-gcp-project"
  region  = "europe-west4"
}

module "castai_gcp_edge_location" {
  source = "castai/omni-edge-location-gcp/castai"

  cluster_id      = var.cluster_id
  organization_id = var.organization_id
  region          = "europe-west4"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_castai"></a> [castai](#requirement\_castai) | >= 8.29.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [castai_edge_location.this](https://registry.terraform.io/providers/castai/castai/latest/docs/resources/edge_location) | resource |
| [google_compute_address.nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.allow_tag](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_project_iam_member.castai_compute_instance_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.castai_service_account_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.castai](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.castai_token_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [castai_omni_cluster.this](https://registry.terraform.io/providers/castai/castai/latest/docs/data-sources/omni_cluster) | data source |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [http_http.zones](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | CAST AI cluster ID | `string` | n/a | yes |
| <a name="input_control_plane"></a> [control\_plane](#input\_control\_plane) | Edge location control plane configuration.<br/>- ha (bool): enable high availability mode for the Edge location control plane (default: true) | <pre>object({<br/>    ha = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the edge location | `string` | `null` | no |
| <a name="input_instance_service_account"></a> [instance\_service\_account](#input\_instance\_service\_account) | GCP service account email to be attached to edge instances. It can be used to grant permissions to access other GCP resources | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the edge location. If not provided, will be auto-generated | `string` | `null` | no |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | Network tags for firewall rules | `list(string)` | <pre>[<br/>  "omni-enabled"<br/>]</pre> | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | CAST AI organization ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region | `string` | n/a | yes |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR block for the edge location subnet | `string` | `"10.0.0.0/20"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_edge_location_id"></a> [edge\_location\_id](#output\_edge\_location\_id) | CAST AI edge location ID |
| <a name="output_edge_location_name"></a> [edge\_location\_name](#output\_edge\_location\_name) | CAST AI edge location name |
| <a name="output_gcp_resources"></a> [gcp\_resources](#output\_gcp\_resources) | GCP resources created for the edge location |
<!-- END_TF_DOCS -->

## License

MIT