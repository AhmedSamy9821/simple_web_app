# Cloud storage module

module "cloud_storage_bucket" {
  source      = "./modules/cloud_storage"
  env         = var.env
  region      = var.region
}
