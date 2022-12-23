data "google_compute_zones" "available" {
       project = data.google_project.project.number
       region  = var.region
       status  = "UP"
}

data "google_project" "project" {
       project_id = var.project
}