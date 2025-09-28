output "notification_channel" {
  value = google_monitoring_notification_channel.email.id
}

output "alert_policies" {
  value = [
    google_monitoring_alert_policy.errors_5xx.id,
    google_monitoring_alert_policy.cpu_high.id,
    google_monitoring_alert_policy.memory_high.id,
    google_monitoring_alert_policy.latency_high.id,
    google_monitoring_alert_policy.instances_high.id
  ]
}

output "dashboard" {
  value = google_monitoring_dashboard.cloud_run_dashboard.id
}
