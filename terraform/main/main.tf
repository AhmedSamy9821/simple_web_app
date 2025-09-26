/*
# Cloud storage module

module "cloud_storage_bucket" {
  source      = "../modules/cloud_storage"
  project_id = var.project_id
  env         = var.env
  region      = var.region
}

# vpc , subnet , firewall rules module

module "vpc" {
    source  = "../modules/vpc"
    project_id = var.project_id
    env         = var.env
    region      = var.region
    subnet_range = var.subnet_range
}*/
