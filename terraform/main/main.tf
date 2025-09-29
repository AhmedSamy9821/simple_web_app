
#This is the root module 


#create network ( vpc , subnet )
module "vpc" {
    source  = "../modules/vpc"
    project_id = var.project_id
    env         = var.env
    vpc_name    = var.vpc_name
    first_subnet_name = var.first_subnet_name
    first_subnet_region      = var.region
    first_subnet_range = var.first_subnet_range
}



#Create assets cloud storage bucket to save the files uploaded on cloud run service

module "assets_bucket" {
  source      = "../modules/cloud_storage"
  project_id = var.project_id
  env         = var.env
  region      = var.region
  bucket_name = var.assets_bucket_name
  class       = var.assets_bucket_class
}


#Deploy cloud run service which will be the compute resource of the application

module "cloud_run_service" {
  source      =  "../modules/cloud_run"
  project_id  = var.project_id
  env         = var.env
  region      = var.region
  service_name = var.cloud_run_service_name
  assets_bucket_name = module.assets_bucket.bucket_name
  min_scale   = var.cloud_run_min_instances
  max_scale   =  var.cloud_run_max_instances
  started_image = var.cloud_run_started_image
  port        = var.cloud_run_port
}


#create policy alerts to notify on notification channel and create monitoring dashboard

module "monitoring" {
  source                  = "../modules/monitor"
  cloud_run_service_name  = module.cloud_run_service.cloud_run_service_name
  cloud_run_max_instances = var.cloud_run_max_instances
  notification_email      = var.notification_email
}


#export cloud run logs to cloud storage bucket to save it for future auditing
module "logging_export" {
  source      = "../modules/logging_export"
  project_id  = var.project_id
  env         = var.env
  region      = var.region
  bucket_name = var.logs_bucket_name
  class       = var.logs_bucket_class
  filter      = var.logs_sink_filter

  depends_on = [module.cloud_run_service]
}


# create load balancer to forward the traffic to cloud run
# also we can use it for custom domain and ssl certificate and frwarding base on the path and subdomain
module "load_balancer" {
source              = "../modules/load_balancer"
lb_name             = var.load_balancer_name
region              = var.region
cloud_run_service   = module.cloud_run_service.cloud_run_service_name
cloud_run_service_host       = module.cloud_run_service.service_host
}