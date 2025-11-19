# terraform-castai-omni-edge-location-gcp

Terraform module for creating CAST AI edge locations in Google Cloud Platform (GCP).

This module automates the provisioning of GCP infrastructure required for CAST AI edge locations, including:
- Service account with necessary IAM roles
- VPC network and subnet
- Firewall rules for edge location connectivity
- CAST AI edge location registration

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

  tags = {
    ManagedBy = "terraform"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_castai"></a> [castai](#requirement\_castai) | >= 8.1.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_castai"></a> [castai](#provider\_castai) | 8.2.1 |
| <a name="provider_google"></a> [google](#provider\_google) | 7.12.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [castai_edge_location.this](https://registry.terraform.io/providers/castai/castai/latest/docs/resources/edge_location) | resource |
| [google_compute_firewall.allow](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_project_iam_member.castai_compute_instance_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.castai_service_account_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.castai](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.castai](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [http_http.zones](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | CAST AI cluster ID | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the edge location | `string` | `null` | no |
| <a name="input_firewall_source_ranges"></a> [firewall\_source\_ranges](#input\_firewall\_source\_ranges) | Source IP ranges for firewall ingress rules | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the edge location. If not provided, will be auto-generated | `string` | `null` | no |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | Network tags for firewall rules | `list(string)` | <pre>[<br/>  "omni-enabled"<br/>]</pre> | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | CAST AI organization ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region | `string` | n/a | yes |
| <a name="input_subnet_cidr_pool"></a> [subnet\_cidr\_pool](#input\_subnet\_cidr\_pool) | CIDR pool for subnet allocation | `string` | `"10.0.0.0/8"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Labels to apply to GCP resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_edge_location_id"></a> [edge\_location\_id](#output\_edge\_location\_id) | CAST AI edge location ID |
| <a name="output_edge_location_name"></a> [edge\_location\_name](#output\_edge\_location\_name) | CAST AI edge location name |
| <a name="output_gcp_resources"></a> [gcp\_resources](#output\_gcp\_resources) | GCP resources created for the edge location |
<!-- END_TF_DOCS -->

## License

MIT