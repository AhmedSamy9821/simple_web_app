# providers.tf variables
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

# main.tf variables
variable "env" {
  description = "Environment (dev, staging, prod, uat)"
  type = string
}
variable "region" {
  type = string
}