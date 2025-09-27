
#create network ( vpc , subnet , firewall rules)

module "vpc" {
    source  = "../modules/vpc"
    project_id = var.project_id
    env         = var.env
    vpc_name    = var.vpc_name
    first_subnet_name = var.first_subnet_name
    first_subnet_region      = var.region
    first_subnet_range = var.first_subnet_range
}



#Create assets cloud storage bucket

module "cloud_storage_bucket" {
  source      = "../modules/cloud_storage"
  project_id = var.project_id
  env         = var.env
  region      = var.region
  bucket_name = var.assets_bucket_name
  class       = var.assets_bucket_class
}

#create logging cloud storage bucket

module "cloud_storage_bucket" {
  source      = "../modules/cloud_storage"
  project_id = var.project_id
  env         = var.env
  region      = var.region
  bucket_name = var.logging_bucket_name
  class       = var.logging_bucket_class
}

