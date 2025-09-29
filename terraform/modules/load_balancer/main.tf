# Serverless NEG for Cloud Run
resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  name                  = "${var.cloud_run_service}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.cloud_run_service
  }
}

# Backend service
resource "google_compute_backend_service" "cloud_run_backend" {
  name        = "${var.cloud_run_service}-backend"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30

  backend {
    group = google_compute_region_network_endpoint_group.cloudrun_neg.id
  }

}

# Health check
resource "google_compute_health_check" "health_check" {
  name = "${var.cloud_run_service}-hc"

  http_health_check {
    port_specification = "USE_SERVING_PORT"
    request_path       = "/health"
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# URL map
resource "google_compute_url_map" "url_map" {
  name            = "${var.lb_name}-urlmap"

   default_route_action {
    url_rewrite {
      host_rewrite = var.cloud_run_service_host
    }

   }

  default_service = google_compute_backend_service.cloud_run_backend.self_link
}

# HTTP target proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "${var.lb_name}-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

# Global forwarding rule
resource "google_compute_global_forwarding_rule" "fwd_rule" {
  name       = "${var.lb_name}-fwd"
  target     = google_compute_target_http_proxy.http_proxy.self_link
  port_range = "80"
  ip_protocol = "TCP"
  load_balancing_scheme = "EXTERNAL"
}
