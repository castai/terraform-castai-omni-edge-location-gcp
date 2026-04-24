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
}

# Data source to get access token and project from provider
data "google_client_config" "current" {}

# Fetch CAST AI Omni cluster OIDC config for service account impersonation
data "castai_omni_cluster" "this" {
  organization_id = var.organization_id
  cluster_id      = var.cluster_id
}

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

# Allow CAST AI service account to impersonate this service account
resource "google_service_account_iam_member" "castai_token_creator" {
  service_account_id = google_service_account.castai.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${data.castai_omni_cluster.this.castai_oidc_config.gcp_service_account_email}"
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
  name                     = local.subnet_name
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true
  description              = "Subnet created for Cast AI Omni edges in ${var.region}"
}

# =============================================================================
# Firewall Rules
# =============================================================================

resource "google_compute_firewall" "allow_tag" {
  name    = "${local.network_name}-allow-tag"
  network = google_compute_network.main.name

  allow {
    protocol = "all"
  }

  source_tags = var.network_tags
  target_tags = var.network_tags
  direction   = "INGRESS"
  priority    = 1000
  description = "Allow all ingress traffic between Cast AI OMNI tagged instances"
}

# =============================================================================
# Cloud Router and NAT
# =============================================================================

resource "google_compute_router" "main" {
  name    = "${local.network_name}-router"
  project = data.google_client_config.current.project
  network = google_compute_network.main.id
  region  = var.region
}

resource "google_compute_address" "nat" {
  name    = "${local.network_name}-nat-ip"
  project = data.google_client_config.current.project
  region  = var.region
}

resource "google_compute_router_nat" "main" {
  name                               = "${local.network_name}-nat"
  project                            = data.google_client_config.current.project
  router                             = google_compute_router.main.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
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

  control_plane      = var.control_plane
  control_plane_mode = "SHARED"

  # GCP cloud provider configuration
  gcp = {
    project_id                   = data.google_client_config.current.project
    instance_service_account     = var.instance_service_account
    target_service_account_email = google_service_account.castai.email
    network_name                 = google_compute_network.main.name
    subnet_name                  = google_compute_subnetwork.main.name
    subnet_cidr                  = var.subnet_cidr
    network_tags                 = var.network_tags
  }

  # Ensure IAM and networking resources are destroyed only after the edge location
  # is deleted. Without this, `terraform destroy` removes IAM impersonation bindings
  # in parallel with the edge location, leaving user unable to clean up active edges 
  # without manually restoring those bindings.
  depends_on = [
    google_service_account_iam_member.castai_token_creator,
    google_project_iam_member.castai_compute_instance_admin,
    google_project_iam_member.castai_service_account_user,
    google_compute_router_nat.main,
    google_compute_firewall.allow_tag,
  ]
}
