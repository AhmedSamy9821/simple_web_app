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