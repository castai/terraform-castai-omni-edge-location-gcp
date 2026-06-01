data "google_project" "current" {}

data "google_client_config" "default" {}

data "google_container_cluster" "gke" {
  name     = var.gke_cluster_name
  location = var.gke_cluster_region
  project  = data.google_project.current.project_id
}

# =============================================================================
# Onboard cluster to CAST AI
# =============================================================================

module "castai-gke-iam" {
  source  = "castai/gke-iam/castai"
  version = "~> 0.5"

  project_id       = data.google_project.current.project_id
  gke_cluster_name = data.google_container_cluster.gke.name
}

module "castai-gke-cluster" {
  source  = "castai/gke-cluster/castai"
  version = "~> 10"

  api_url          = var.castai_api_url
  castai_api_token = var.castai_api_token

  project_id           = data.google_project.current.project_id
  gke_cluster_name     = data.google_container_cluster.gke.name
  gke_cluster_location = data.google_container_cluster.gke.location
  gke_credentials      = module.castai-gke-iam.private_key

  wait_for_cluster_ready          = true
  default_node_configuration_name = "default"

  node_configurations = {
    default = {
      subnets = [data.google_container_cluster.gke.subnetwork]
    }
  }

  install_omni = true
}

# =============================================================================
# Create edge locations
# =============================================================================

module "castai_gcp_edge_location" {
  source = "../.."

  cluster_id                      = module.castai-gke-cluster.cluster_id
  organization_id                 = module.castai-gke-cluster.organization_id
  region                          = "europe-west4"
  default_edge_configuration_name = "gpu"

  edge_configurations = {
    gpu = {
      name               = "GPU configuration"
      image_id           = "projects/ml-images/global/images/family/common-gpu"  # GPU-enabled GCP image
      boot_disk_size_gib = 200
      labels = {
        workload    = "gpu"
        environment = "production"
      }
      user_data_base64 = "IyEvYmluL2Jhc2gKCmVjaG8gImhlbGxvIHdvcmxkIGZyb20gY3VzdG9tIHNjcmlwdCI="
    }
  }

  depends_on = [module.castai-gke-cluster]
}
