#export logs to cloud storage


resource "google_storage_bucket" "logs_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true
  
  storage_class = var.class
  uniform_bucket_level_access = true

  labels = {
    environment = var.env
  }
}

resource "google_logging_project_sink" "cloudrun_logs_sink" {
  name        = "${var.bucket_name}-sink"
  destination = "storage.googleapis.com/${google_storage_bucket.logs_bucket.name}"
  filter      = var.filter
}

resource "google_storage_bucket_iam_member" "logs_sink_writer" {
  bucket = google_storage_bucket.logs_bucket.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.cloudrun_logs_sink.writer_identity
}

