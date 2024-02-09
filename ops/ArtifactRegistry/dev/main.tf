
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
    bucket = "nadeemstoragebucket" # GCS bucket name to store terraform tfstate
    prefix = "cicd-usecase/dev/ArtifactRegistry"               # Prefix name should be unique for each Terraform project having same remote state bucket.
  }
}
provider "google" {
  project = "planar-sun-412213"
}
resource "google_artifact_registry_repository" "my-repo" {
  location      = var.location
  repository_id = var.repository_id
  description   = "For docker repository"
  format        = var.format

  docker_config {
    immutable_tags = false
  }
}
