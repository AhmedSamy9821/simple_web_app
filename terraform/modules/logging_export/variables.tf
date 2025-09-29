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

variable "filter" {
    description = "This filter will be used to filter cloud run logs to export them to logs cloud storage bucket"
    type        = string
}