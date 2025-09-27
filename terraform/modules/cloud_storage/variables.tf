variable "project_id" {
  type = string
}

variable "env" {
  description = "Environment (dev, staging, prod, uat)"
  type = string
}
variable "region" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "class" {
  type = string
  description = "the bucket class"
}