output "vpc_id" {
  value       = google_compute_network.vpc.network_id
}

output "first_subnet_state" {
    value      = google_compute_subnetwork.first_subnet.state
}