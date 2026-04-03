output "edge_location_id" {
  description = "CAST AI edge location ID"
  value       = castai_edge_location.this.id
}

output "edge_location_name" {
  description = "CAST AI edge location name"
  value       = castai_edge_location.this.name
}

output "gcp_resources" {
  description = "GCP resources created for the edge location"
  value = {
    project_id   = data.google_client_config.current.project
    network_name = google_compute_network.main.name
    subnet_name  = google_compute_subnetwork.main.name
    router_name  = google_compute_router.main.name
    nat_ip       = google_compute_address.nat.address
  }
}