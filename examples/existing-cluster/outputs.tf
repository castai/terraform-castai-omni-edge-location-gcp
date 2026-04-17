output "edge_location_id" {
  description = "CAST AI edge location ID"
  value       = module.castai_gcp_edge_location.edge_location_id
}

output "edge_location_name" {
  description = "CAST AI edge location name"
  value       = module.castai_gcp_edge_location.edge_location_name
}

output "gcp_resources" {
  description = "GCP resources created for the edge location"
  value       = module.castai_gcp_edge_location.gcp_resources
}
