output "bucket_name" {
  value = google_storage_bucket.logs_bucket.name
}

output "sink_writer_identity" {
  value = google_logging_project_sink.cloudrun_logs_sink.writer_identity
}
