#This module is for creating assets cloud storage
#enable storage api 
resource "google_project_service" "storage_api" {
  project = var.project_id
  service = "storage.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "simple_app_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true
  
  storage_class = var.class
  uniform_bucket_level_access = true  #to control the permission through IAM

  labels = {
    environment = var.env
  }

}