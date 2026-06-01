variable "name" {
  type        = string
  description = "Name for the edge location. If not provided, will be auto-generated"
  default     = null
}

variable "cluster_id" {
  type        = string
  description = "CAST AI cluster ID"
}

variable "organization_id" {
  type        = string
  description = "CAST AI organization ID"
}

variable "description" {
  type        = string
  description = "Description of the edge location"
  default     = null
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the edge location subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "network_tags" {
  description = "Network tags for firewall rules"
  type        = list(string)
  default     = ["omni-enabled"]
}

variable "instance_service_account" {
  description = "GCP service account email to be attached to edge instances. It can be used to grant permissions to access other GCP resources"
  type        = string
  default     = ""
}


variable "control_plane" {
  description = <<-EOT
    Edge location control plane configuration.
    - ha (bool): enable high availability mode for the Edge location control plane (default: true)
  EOT
  type = object({
    ha = optional(bool, true)
  })
  default = {}
}

variable "networking" {
  description = <<-EOT
    Edge cluster networking configuration.
    - tunneled_cidrs (list(string)): list of destination CIDR blocks whose traffic should be routed through the main cluster instead of directly from the edge cluster.
  EOT
  type = object({
    tunneled_cidrs = optional(list(string))
  })
  default = null
}

variable "edge_configurations" {
  description = <<-EOT
    Map of GCP edge configurations to create for this edge location.

    Each configuration supports the following attributes:
    - name (string, optional): Name of the edge configuration. Defaults to the map key.
    - image_id (string, optional): Boot disk image name or family for edge instances (e.g., "projects/debian-cloud/global/images/family/debian-12" or "cos-101-lts").
    - boot_disk_size_gib (number, optional): Boot disk size in GiB.
    - user_data_base64 (string, optional): Base64 encoded user data to run on the edge as part of bootstrap. The payload must start with either `#cloud-config` (cloud-init YAML) or `#!` (shell script with a shebang).
    - labels (map(string), optional): Labels to apply to edge instances created with this configuration.
    - cri (map(string), optional): Container runtime interface configuration. Defaults to `{}`.

    Example:
    edge_configurations = {
      "default" = {
        image_id = "projects/debian-cloud/global/images/family/debian-12"
        labels = {
          environment = "production"
        }
      }
      "gpu" = {
        image_id           = "projects/ml-images/global/images/family/common-gpu"
        boot_disk_size_gib = 200
        labels = {
          workload = "gpu"
        }
      }
    }
  EOT
  type = map(object({
    name               = optional(string)
    image_id           = optional(string)
    boot_disk_size_gib = optional(number)
    user_data_base64   = optional(string)
    cri                = optional(map(string), {})
    labels             = optional(map(string), {})
  }))
  default = {}
}
