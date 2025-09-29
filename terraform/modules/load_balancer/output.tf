output "lb_ip" {
  value       = google_compute_global_forwarding_rule.fwd_rule.ip_address
  description = "External IP of the HTTP load balancer"
}

output "lb_url" {
  value       = "http://${google_compute_global_forwarding_rule.fwd_rule.ip_address}"
  description = "URL to access the load balancer"
}