variable "castai_api_token" {
  type        = string
  sensitive   = true
  description = "CAST AI API token"
}

variable "castai_api_url" {
  type        = string
  description = "CAST AI API URL"
  default     = "https://api.cast.ai"
}

variable "cluster_id" {
  type        = string
  description = "Existing CAST AI cluster ID"
}

variable "organization_id" {
  type        = string
  description = "CAST AI organization ID"
}

variable "gcp_project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region for the edge location"
}

variable "name" {
  type        = string
  description = "Name for the edge location. If not provided, will be auto-generated"
  default     = null
}

variable "description" {
  type        = string
  description = "Description of the edge location"
  default     = null
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

