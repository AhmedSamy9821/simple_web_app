#vpc module outputs
output "vpc_id" {
  value       = module.vpc.vpc_id
}

output "first_subnet_state" {
    value      = module.vpc.first_subnet_state
}


#cloud run module outputs
output "cloud_run_url" {
    value = module.cloud_run_service.cloud_run_url
    description = "the url that will distribute traffic over the provided traffic targets"
}

#load_balancer outputs
output "lb_url" {
  value       = module.load_balancer.lb_url
  description = "URL to access the load balancer"
}



