# providers.tf variables
########################


# global variables
#################
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "env" {
  description = "Environment (dev, staging, prod, uat)"
  type = string
}

variable "region" {
  type = string
}



#vpc variables
#############

variable "vpc_name" {
  type = string
}

variable "first_subnet_name" {
  type = string
}

variable "first_subnet_range" {
  type = string
}


#storage buckets variables 
############################

variable "assets_bucket_name" {
  type = string
}

variable "assets_bucket_class" {
  type = string
}


variable "logging_bucket_name" {
  type = string
}

variable "logging_bucket_class" {
  type = string
}


#cloud run variables
####################
variable "cloud_run_service_name" {
  type = string
}


variable "cloud_run_min_instances" {
  description = "The minimum number of instances that up even there is no traffic"
  type = string
}

variable "cloud_run_max_instances" {
  description = "The max number of instances"
  type = string
}

variable "cloud_run_started_image" {
  description = "The first image will be deployed on the cloud run service" #will be changed by cicd pipeline
  type = string
}


variable "cloud_run_port" {
  description = "Container port" #will be changed by cicd pipeline
  type = string
}



#monitoring and logging variables
################################

variable "notification_email" {
  description = "Email address for alert notifications"
  type        = string
}

variable "logs_bucket_name" {
  type        = string
}

variable "logs_bucket_class" {
  type = string
}

variable "logs_sink_filter" {
  type = string
}



