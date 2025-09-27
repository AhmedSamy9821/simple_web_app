
variable "env" {
  description = "Environment (dev, staging, prod, uat)"
  type = string
}

variable "assets_bucket_name" {
  description = "The bucket name of assets bucket which cloud run will upload assets to it"
  type = string
}

variable "service_name" {
  description = "The cloud run service name"
  type = string
}

variable "region" {
  description = "The region which the cloud run service will be deployed in "
  type = string
}

variable "project_id" {
  type = string
}

variable "min_scale" {
  description = "The minimum number of instances that up even there is no traffic"
  type = string
}

variable "max_scale" {
  description = "The max number of instances"
  type = string
}

variable "started_image" {
  description = "The first image will be deployed on the cloud run service" #will be changed by cicd pipeline
  type = string
}


variable "port" {
  description = "Container port" #will be changed by cicd pipeline
  type = string
}




