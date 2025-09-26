# Cloud storage module

module "cloud storage bucket" {
  source      = "./modules/cloud_storage"
  env         = var.env
  region      = var.region
}
