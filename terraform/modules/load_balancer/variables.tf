variable "lb_name" {
  type = string
}

variable "region" {
    type = string
}

variable "cloud_run_service" {
    description = "The name of the Cloud Run service"
    type = string
}

variable "cloud_run_service_host" {
    description = "Host of the Cloud Run service for host rewrite in LB"
    type = string
}
