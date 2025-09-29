output "cloud_run_service_name" {
  value       = google_cloud_run_service.simple-web-app.name
  description = "The name of the Cloud Run service"
}

output "cloud_run_url" {
    value = google_cloud_run_service.simple-web-app.status[0].url
    description = "the url that will distribute traffic over the provided traffic targets"
}

output "service_host" {
  value       = replace(google_cloud_run_service.simple-web-app.status[0].url, "https://", "")
  description = "Host of the Cloud Run service for host rewrite in LB"
}