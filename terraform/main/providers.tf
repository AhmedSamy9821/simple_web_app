provider "google" {
  project = var.project_id
  region  = "me-central1" # I assumed that the project will be on gulf region so that i choose me-central1 for the best user experience
                         
}
