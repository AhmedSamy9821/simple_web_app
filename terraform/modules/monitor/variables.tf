variable "cloud_run_service_name" {
  description = "Cloud Run service name"
  type        = string
}

variable "cloud_run_max_instances" {
  description = "Max instances of the Cloud Run service"
  type        = number
}

variable "notification_email" {
  description = "Email address for alert notifications"
  type        = string
}
