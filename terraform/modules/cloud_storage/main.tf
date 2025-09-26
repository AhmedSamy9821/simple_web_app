resource "google_storage_bucket" "simple_app_bucket" {
  name          = "${var.env}-simple_app_bucket"
  location      = var.region
  force_destroy = true
  
  storage_class = "STANDARD"
  uniform_bucket_level_access = true

  labels = {
    environment = var.env
  }

}