
terraform {
  required_version = "~> 0.14"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.69.1"
    }
  }
}
terraform {
  backend "gcs" {
    bucket = "anil-terraform-statefiles" # GCS bucket name to store terraform tfstate
    prefix = "cicd-demo/prod/terraform.tfstate"               # Prefix name should be unique for each Terraform project having same remote state bucket.
  }
}
provider "google" {
  project = "excellent-guide-410011"
}
resource "google_cloud_run_v2_service" "default" {
  name     = var.name
  location = var.location
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "asia-south1-docker.pkg.dev/excellent-guide-410011/cicd-demo-prod-repository/pythondemoimage:latest"
      resources {
        limits = {
          cpu    = "4"
          memory = "2048Mi"
        }
      }
    }
  }
}