module "castai_gcp_edge_location" {
  source = "../.."

  cluster_id      = var.cluster_id
  organization_id = var.organization_id

  region        = var.region
  name          = var.name
  description   = var.description
  control_plane = var.control_plane
}
