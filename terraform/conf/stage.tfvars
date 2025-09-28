#global variables
env = "stage"
region = "me-central1"

#buckets variables
assets_bucket_name = "stage-assets-simple-web-app"
assets_bucket_class = "STANDARD"
logging_bucket_name = "stage-logging-simple-web-app"
logging_bucket_class = "NEARLINE"

# vpc variables
vpc_name            = "stage-simple-web-app-vpc"
first_subnet_name   = "stage-first-simple-web-app-subnet"
first_subnet_range = "10.0.2.0/24"

#cloud run variables
cloud_run_service_name = "stage-simple-web-app"
cloud_run_min_instances = "1"
cloud_run_max_instances = "10"
cloud_run_started_image = "us-docker.pkg.dev/cloudrun/container/hello"
cloud_run_port          = "8080"


#monitor and logging variables
notification_email  = "ahmedsami2302@gmail.com"
logs_bucket_name    = "stage-logging-simple-web-app"
logs_bucket_class   = "NEARLINE"
logs_sink_filter    = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"stage-simple-web-app""

