variable "project_id" {
  description = "Environment (dev, staging, prod, uat)"
  type = string
}

variable "env" {
  description = "Environment (dev, staging, prod, uat)"
  type = string
}



variable "vpc_name" {
  type = string
}

variable "first_subnet_name" {
  type = string
}


variable "first_subnet_region" {
  type = string
}

variable "first_subnet_range" {
  type = string
}

