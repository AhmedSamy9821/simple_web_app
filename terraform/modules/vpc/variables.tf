variable "project_id" {
  description = "Environment (dev, staging, prod, uat)"
  type = string
}

variable "env" {
  description = "Environment (dev, staging, prod, uat)"
  type = string
}



variables "vpc_name" {
  type = string
}

variables "first_subnet_name" {
  type = string
}


variable "first_subnet_region" {
  type = string
}

variable "first_subnet_range" {
  type = string
}

