locals {
  service_filter = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${var.cloud_run_service_name}\""
}

/* Notification Channel */
resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notifications for ${var.cloud_run_service_name}"
  type         = "email"
  labels = {
    email_address = var.notification_email
  }
}

/* 5xx Errors */
resource "google_monitoring_alert_policy" "errors_5xx" {
  display_name          = "Cloud Run ${var.cloud_run_service_name} - High 5xx"
  notification_channels = [google_monitoring_notification_channel.email.id]
  combiner              = "OR"

  conditions {
    display_name = "5xx > 5 in 1m"
    condition_threshold {
      filter          = "metric.type=\"run.googleapis.com/request_count\" AND metric.label.\"response_code_class\"=\"5xx\" AND ${local.service_filter}"
      comparison      = "COMPARISON_GT"
      threshold_value = 5
      duration        = "60s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
    }
  }
}

/* CPU */
resource "google_monitoring_alert_policy" "cpu_high" {
  display_name          = "Cloud Run ${var.cloud_run_service_name} - High CPU"
  notification_channels = [google_monitoring_notification_channel.email.id]
  combiner              = "OR"

  conditions {
    display_name = "CPU > 80%"
    condition_threshold {
      filter          = "metric.type=\"run.googleapis.com/container/cpu/utilizations\" AND ${local.service_filter}"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      duration        = "120s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_PERCENTILE_99"
      }
    }
  }
}

/* Memory */
resource "google_monitoring_alert_policy" "memory_high" {
  display_name          = "Cloud Run ${var.cloud_run_service_name} - High Memory"
  notification_channels = [google_monitoring_notification_channel.email.id]
  combiner              = "OR"

  conditions {
    display_name = "Memory > 80%"
    condition_threshold {
      filter          = "metric.type=\"run.googleapis.com/container/memory/utilizations\" AND ${local.service_filter}"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      duration        = "120s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_PERCENTILE_99"
      }
    }
  }
}

/* Latency */
resource "google_monitoring_alert_policy" "latency_high" {
  display_name          = "Cloud Run ${var.cloud_run_service_name} - High Latency"
  notification_channels = [google_monitoring_notification_channel.email.id]
  combiner              = "OR"

  conditions {
    display_name = "p95 latency > 1000ms"
    condition_threshold {
      filter          = "metric.type=\"run.googleapis.com/request_latencies\" AND ${local.service_filter}"
      comparison      = "COMPARISON_GT"
      threshold_value = 1000
      duration        = "60s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_PERCENTILE_95"
      }
    }
  }
}

/* Instances >= 75% of max */
resource "google_monitoring_alert_policy" "instances_high" {
  display_name          = "Cloud Run ${var.cloud_run_service_name} - High Instance Count"
  notification_channels = [google_monitoring_notification_channel.email.id]
  combiner              = "OR"

  conditions {
    display_name = "Instance count >= 75% of max"
    condition_threshold {
      filter          = "metric.type=\"run.googleapis.com/container/instance_count\" AND ${local.service_filter}"
      comparison      = "COMPARISON_GT"
      threshold_value = var.cloud_run_max_instances * 0.75
      duration        = "60s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MAX"
      }
    }
  }
}

/* Dashboard */
resource "google_monitoring_dashboard" "cloud_run_dashboard" {
  dashboard_json = jsonencode({
    displayName = "Cloud Run - ${var.cloud_run_service_name}"
    gridLayout = {
      columns = 2
      widgets = [
        { title = "Requests", xyChart = { dataSets = [{ timeSeriesQuery = { timeSeriesFilter = { filter = "metric.type=\"run.googleapis.com/request_count\" AND ${local.service_filter}" } } }] } },
        { title = "5xx Errors", xyChart = { dataSets = [{ timeSeriesQuery = { timeSeriesFilter = { filter = "metric.type=\"run.googleapis.com/request_count\" AND metric.label.response_code_class=\"5xx\" AND ${local.service_filter}" } } }] } },
        { title = "CPU", xyChart = { dataSets = [{ timeSeriesQuery = { timeSeriesFilter = { filter = "metric.type=\"run.googleapis.com/container/cpu/utilizations\" AND ${local.service_filter}" } } }] } },
        { title = "Memory", xyChart = { dataSets = [{ timeSeriesQuery = { timeSeriesFilter = { filter = "metric.type=\"run.googleapis.com/container/memory/utilizations\" AND ${local.service_filter}" } } }] } },
        { title = "Latency (p95)", xyChart = { dataSets = [{ timeSeriesQuery = { timeSeriesFilter = { filter = "metric.type=\"run.googleapis.com/request_latencies\" AND ${local.service_filter}" } } }] } },
        { title = "Instance Count", xyChart = { dataSets = [{ timeSeriesQuery = { timeSeriesFilter = { filter = "metric.type=\"run.googleapis.com/container/instance_count\" AND ${local.service_filter}" } } }] } }
      ]
    }
  })
}
