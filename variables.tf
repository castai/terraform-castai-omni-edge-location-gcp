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

variable "subnet_cidr_pool" {
  description = "CIDR pool for subnet allocation"
  type        = string
  default     = "10.0.0.0/8"
}

variable "firewall_source_ranges" {
  description = "Source IP ranges for firewall ingress rules"
  type        = list(string)
  default     = ["0.0.0.0/0"]
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
