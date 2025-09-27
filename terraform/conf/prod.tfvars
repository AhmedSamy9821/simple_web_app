#global variables
env = "prod"
region = "me-central1"

#buckets variables
assets_bucket_name = "prod-assets-simple-web-app"
assets_bucket_class = "STANDARD"
logging_bucket_name = "prod-logging-simple-web-app"
logging_bucket_class = "NEARLINE"

#vpc variables
vpc_name            = "prod-simple-web-app-vpc"
first_subnet_name   = "prod-first-simple-web-app-subnet"
first_subnet_range = "10.0.1.0/24"

#cloud run variables
cloud_run_service_name = "prod-simple-web-app"
cloud_run_min_instances = "1"
cloud_run_max_instances = "10"
cloud_run_started_image = "us-docker.pkg.dev/cloudrun/container/hello"
cloud_run_port          = "8080"



