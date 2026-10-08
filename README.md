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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_castai"></a> [castai](#requirement\_castai) | >= 9.6.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [castai_edge_configuration.this](https://registry.terraform.io/providers/castai/castai/latest/docs/resources/edge_configuration) | resource |
| [castai_edge_configuration_default.this](https://registry.terraform.io/providers/castai/castai/latest/docs/resources/edge_configuration_default) | resource |
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
| <a name="input_addons"></a> [addons](#input\_addons) | Optional addons to install on the edge cluster. Defaults to null (provider installs nvidia-gpu-operator by default).<br/>Set to an empty list to install no addons.<br/><br/>Each addon supports:<br/>- name (string, required): Addon identifier. One of: nvidia-gpu-operator, nvidia-dra, nvidia-network-operator, oci-csi.<br/>- values (string, optional): Helm values for the addon, encoded as a JSON object. | <pre>list(object({<br/>    name   = string<br/>    values = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | CAST AI cluster ID | `string` | n/a | yes |
| <a name="input_control_plane"></a> [control\_plane](#input\_control\_plane) | Edge location control plane configuration.<br/>- ha (bool): enable high availability mode for the Edge location control plane (default: true)<br/>- external\_address (string, optional): the IP address or hostname used to reach the API server from outside the cluster, if in-cluster LoadBalancer services are not reachable (e.g. cluster is hidden behind an external LoadBalancer).<br/>- api\_server\_port (number, optional): the port used for the API server. Defaults to the system value when unset.<br/>- konnectivity\_port (number, optional): the port used for the konnectivity server. Defaults to the system value when unset.<br/>- service\_annotations (map(string), optional): custom annotations to apply to the control plane service. | <pre>object({<br/>    ha                  = optional(bool, true)<br/>    external_address    = optional(string)<br/>    api_server_port     = optional(number)<br/>    konnectivity_port   = optional(number)<br/>    service_annotations = optional(map(string))<br/>  })</pre> | `{}` | no |
| <a name="input_default_edge_configuration_name"></a> [default\_edge\_configuration\_name](#input\_default\_edge\_configuration\_name) | Name of the default edge configuration | `string` | `""` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the edge location | `string` | `null` | no |
| <a name="input_edge_configurations"></a> [edge\_configurations](#input\_edge\_configurations) | Map of GCP edge configurations to create for this edge location.<br/><br/>Each configuration supports the following attributes:<br/>- name (string, required): Name of the edge configuration.<br/>- image\_id (string, optional): Boot disk image name or family for edge instances (e.g., "projects/debian-cloud/global/images/family/debian-12" or "cos-101-lts").<br/>- boot\_disk\_size\_gib (number, optional): Boot disk size in GiB.<br/>- user\_data\_base64 (string, optional): Base64 encoded user data to run on the edge as part of bootstrap. The payload must start with either `#cloud-config` (cloud-init YAML) or `#!` (shell script with a shebang).<br/>- labels (map(string), optional): Labels to apply to edge instances created with this configuration.<br/>- cri (map(string), optional): Container runtime interface configuration. Defaults to `{}`.<br/><br/>Example:<br/>edge\_configurations = {<br/>  "default" = {<br/>    image\_id = "projects/debian-cloud/global/images/family/debian-12"<br/>    labels = {<br/>      environment = "production"<br/>    }<br/>  }<br/>  "gpu" = {<br/>    image\_id           = "projects/ml-images/global/images/family/common-gpu"<br/>    boot\_disk\_size\_gib = 200<br/>    labels = {<br/>      workload = "gpu"<br/>    }<br/>  }<br/>} | <pre>map(object({<br/>    name               = string<br/>    image_id           = optional(string)<br/>    boot_disk_size_gib = optional(number)<br/>    user_data_base64   = optional(string)<br/>    cri                = optional(map(string), {})<br/>    labels             = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_instance_service_account"></a> [instance\_service\_account](#input\_instance\_service\_account) | GCP service account email to be attached to edge instances. It can be used to grant permissions to access other GCP resources | `string` | `""` | no |
| <a name="input_liqo"></a> [liqo](#input\_liqo) | Liqo configuration for the edge cluster.<br/>- gateway\_replicas (number, optional): number of active replicas for the Liqo gateway servers and clients. Defaults to 1 when unset.<br/>- gateway\_server (object, optional): configuration overrides for the Liqo gateway server:<br/>  - service\_labels (map(string), optional): custom labels to apply to the Liqo gateway service.<br/>  - service\_annotations (map(string), optional): custom annotations to apply to the Liqo gateway service.<br/>  - external\_address (string, optional): the IP address or hostname used to reach the Liqo gateway server from outside the cluster, if in-cluster LoadBalancer services are not reachable (e.g. cluster is hidden behind an external LoadBalancer).<br/>  - external\_port (number, optional): the port used for the Liqo gateway server. Defaults to the system value when unset. | <pre>object({<br/>    gateway_replicas = optional(number)<br/>    gateway_server = optional(object({<br/>      service_labels      = optional(map(string))<br/>      service_annotations = optional(map(string))<br/>      external_address    = optional(string)<br/>      external_port       = optional(number)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the edge location. If not provided, will be auto-generated | `string` | `null` | no |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | Network tags for firewall rules | `list(string)` | <pre>[<br/>  "omni-enabled"<br/>]</pre> | no |
| <a name="input_networking"></a> [networking](#input\_networking) | Edge cluster networking configuration.<br/>- tunneled\_cidrs (list(string)): list of destination CIDR blocks whose traffic should be routed through the main cluster instead of directly from the edge cluster. | <pre>object({<br/>    tunneled_cidrs = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | CAST AI organization ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region | `string` | n/a | yes |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | CIDR block for the edge location subnet | `string` | `"10.0.0.0/20"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_edge_configuration_ids"></a> [edge\_configuration\_ids](#output\_edge\_configuration\_ids) | Map of edge configuration IDs by configuration key |
| <a name="output_edge_location_id"></a> [edge\_location\_id](#output\_edge\_location\_id) | CAST AI edge location ID |
| <a name="output_edge_location_name"></a> [edge\_location\_name](#output\_edge\_location\_name) | CAST AI edge location name |
| <a name="output_gcp_resources"></a> [gcp\_resources](#output\_gcp\_resources) | GCP resources created for the edge location |
<!-- END_TF_DOCS -->

## License

MIT