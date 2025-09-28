#global variables
env = "uat"
region = "me-central1"


#buckets variables
assets_bucket_name = "uat-assets-simple-web-app"
assets_bucket_class = "STANDARD"
logging_bucket_name = "uat-logging-simple-web-app"
logging_bucket_class = "NEARLINE"

#vpc variables
vpc_name            = "uat-simple-web-app-vpc"
first_subnet_name   = "uat-first-simple-web-app-subnet"
first_subnet_range = "10.0.3.0/24"

#cloud run variables
cloud_run_service_name = "uat-simple-web-app"
cloud_run_min_instances = "0"
cloud_run_max_instances = "10"
cloud_run_started_image = "us-docker.pkg.dev/cloudrun/container/hello"
cloud_run_port          = "8080"


#monitor and logging variables
notification_email  = "ahmedsami2302@gmail.com"
logs_bucket_name    = "uat-logging-simple-web-app"
logs_bucket_class   = "NEARLINE"
logs_sink_filter    = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"uat-simple-web-app""

