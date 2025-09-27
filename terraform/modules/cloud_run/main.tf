#This module for creating cloud run 

#enable mandatory apis for cloud run 
locals {
  apis = [
    "run.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
  ]
}

resource "google_project_service" "enabled" {
  for_each = toset(local.apis)
  project  = var.project_id
  service  = each.key

  disable_on_destroy = false
}


#create service account which be able to upload to assets bucket
resource "google_service_account" "cloud_run_sa" {
  account_id   = "${var.env}-cloud-run-sa"
  display_name = "${var.env} Cloud Run Service Account"
}

#grant the cloud run service account only storage objectCreator for least previlige
resource "google_storage_bucket_iam_member" "bucket_writer" {
  bucket = var.assets_bucket_name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

#cloud run service
resource "google_cloud_run_service" "simple-web-app" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = var.min_scale
        "autoscaling.knative.dev/maxScale" = var.max_scale
        }
    labels = {
    environment = var.env
        }

    }
    spec {
      service_account_name = google_service_account.cloud_run_sa.email

      containers {
        image = var.started_image

        ports {
          container_port = var.port
        }

        env {
          name  = "ASSETS_BUCKET"
          value = var.assets_bucket_name
        }
      }
    }
    }

    
  

  # keep Terraform's traffic config simple (100% to latest revision)
  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    # ignore image changes and traffic so CD can update them without TF trying to revert
    ignore_changes = [
      "template[0].spec[0].containers[0].image",
      "traffic"
    ]
  }
}
  
#turn on Public access for all users to cloud run app
resource "google_cloud_run_service_iam_member" "public_invoker" {
  location = google_cloud_run_service.simple-web-app.location
  project  = google_cloud_run_service.simple-web-app.project
  service  = google_cloud_run_service.simple-web-app.name

  role   = "roles/run.invoker"
  member = "allUsers"
}