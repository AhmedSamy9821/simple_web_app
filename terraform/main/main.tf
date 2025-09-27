
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

module "assets_bucket" {
  source      = "../modules/cloud_storage"
  project_id = var.project_id
  env         = var.env
  region      = var.region
  bucket_name = var.assets_bucket_name
  class       = var.assets_bucket_class
}

#create logging cloud storage bucket

module "logs_bucket" {
  source      = "../modules/cloud_storage"
  project_id = var.project_id
  env         = var.env
  region      = var.region
  bucket_name = var.logging_bucket_name
  class       = var.logging_bucket_class
}

#Deploy cloud run service

module "cloud run service" {
  source      =  "../modules/cloud_run"
  project_id  = var.project_id
  env         = var.env
  region      = var.region
  service_name = var.cloud_run_service_name
  assets_bucket_name = var.assets_bucket_name
  min_scale   = var.cloud_run_min_instances
  max_scale   =  var.cloud_run_max_instances
  started_image = var.cloud_run_started_image
  port        = var.cloud_run_port
}
