#enable compute api to be able to create vpc
resource "google_project_service" "compute_api" {
  project = var.project_id
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false   # disables default subnetworks AND default firewall rules
  routing_mode            = "GLOBAL"

}

resource "google_compute_subnetwork" "first_subnet" {
  name          = var.first_subnet_name
  ip_cidr_range = var.first_subnet_range
  region        = var.first_subnet_region
  network       = google_compute_network.vpc.id

}
