resource "google_compute_network" "vpc" {
  name                    = "${var.env}-vpc"
  auto_create_subnetworks = false   # disables default subnetworks AND default firewall rules
  routing_mode            = "GLOBAL"
  description             = "${var.env} VPC"


  labels = {
    environment = var.env
  }
}

resource "google_compute_subnetwork" "first_subnet" {
  name          = "first-${var.env}-subnet"
  ip_cidr_range = var.subnet_range
  region        = var.region
  network       = google_compute_network.vpc.id


  labels = {
    environment = var.env
  }
}
