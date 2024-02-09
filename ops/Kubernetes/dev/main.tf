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
    bucket = "nadeem-terraform-statefiles" # GCS bucket name to store terraform tfstate
    prefix = "cicd-usecase/dev/Kubernetes"               # Prefix name should be unique for each Terraform project having same remote state bucket.
  }
}
provider "google" {
  project = "	planar-sun-412213"
}

resource "google_container_cluster" "primary" {
  name     = "nadeem-usecase-gke-cluster"
  location = "asia-south1"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = false
  initial_node_count       = 1
}
