# GCP Edge Location for CAST AI

# Generate random suffix for edge location name
resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  # Generate name if not provided (with random suffix)
  generated_name = var.name != null ? var.name : "gcp-${var.region}-${random_id.suffix.hex}"

  # Sanitize name for GCP resource naming
  sanitized_name = lower(replace(local.generated_name, "/[^a-zA-Z0-9-]/", "-"))

  # Service account ID (max 30 chars)
  service_account_id = substr("castai-omni-${local.sanitized_name}", 0, 30)

  # Network and subnet names
  network_name = "castai-omni-${local.sanitized_name}"
  subnet_name  = "castai-omni-${local.sanitized_name}"

  # Simple subnet CIDR allocation - first available /22 from pool
  # For 10.0.0.0/8 pool, this gives us 10.0.0.0/22
  subnet_cidr = cidrsubnet(var.subnet_cidr_pool, 14, 0)
}

# Data source to get access token and project from provider
data "google_client_config" "current" {}

# Data source to get all zones from GCP Compute Engine API
data "http" "zones" {
  url = "https://compute.googleapis.com/compute/v1/projects/${data.google_client_config.current.project}/zones"

  request_headers = {
    Authorization = "Bearer ${data.google_client_config.current.access_token}"
    Accept        = "application/json"
  }
}

locals {
  # Parse zones from API response and filter by region and status locally
  all_zones = try(jsondecode(data.http.zones.response_body).items, [])
  available_zones = [
    for zone in local.all_zones :
    zone if endswith(zone.region, "/regions/${var.region}") && zone.status == "UP"
  ]
}

# =============================================================================
# Service Account and IAM
# =============================================================================

# Service Account for CAST AI
resource "google_service_account" "castai" {
  account_id   = local.service_account_id
  display_name = local.service_account_id
  description  = "The identity used by Cast AI for Edge location management"
}

# Assign roles to service account
resource "google_project_iam_member" "castai_compute_instance_admin" {
  project = data.google_client_config.current.project
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.castai.email}"
}

resource "google_project_iam_member" "castai_service_account_user" {
  project = data.google_client_config.current.project
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.castai.email}"
}

# Create service account key
resource "google_service_account_key" "castai" {
  service_account_id = google_service_account.castai.name

  depends_on = [
    google_project_iam_member.castai_compute_instance_admin,
    google_project_iam_member.castai_service_account_user
  ]
}

# =============================================================================
# VPC Network and Subnet
# =============================================================================

# VPC Network
resource "google_compute_network" "main" {
  name                    = local.network_name
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "main" {
  name          = local.subnet_name
  ip_cidr_range = local.subnet_cidr
  region        = var.region
  network       = google_compute_network.main.id
  description   = "Subnet created for Cast AI Omni edges in ${var.region}"
}

# =============================================================================
# Firewall Rules
# =============================================================================

resource "google_compute_firewall" "allow" {
  name    = "${local.network_name}-allow"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  allow {
    protocol = "udp"
    ports    = ["51840"]
  }

  source_ranges = var.firewall_source_ranges
  target_tags   = var.network_tags
  direction     = "INGRESS"
  priority      = 1001
}

# =============================================================================
# CAST AI Edge Location
# =============================================================================

resource "castai_edge_location" "this" {
  name            = local.generated_name
  region          = var.region
  cluster_id      = var.cluster_id
  organization_id = var.organization_id
  description     = var.description != null ? var.description : "GCP edge location onboarded by Terraform"
  zones = [
    for zone in local.available_zones : {
      id   = tostring(zone.id)
      name = zone.name
    }
  ]

  # GCP cloud provider configuration
  gcp = {
    project_id                            = data.google_client_config.current.project
    client_service_account_json_base64_wo = google_service_account_key.castai.private_key
    network_name                          = google_compute_network.main.name
    subnet_name                           = google_compute_subnetwork.main.name
    network_tags                          = var.network_tags
  }
}
