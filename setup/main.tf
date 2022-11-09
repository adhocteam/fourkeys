terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.18.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
  backend "gcs" {
    bucket  = "people-app-fourkeys-terraform-state"
    prefix  = "terraform.tfstate"
  }
}

resource "google_project_service" "run_api" {
  project = var.google_project_id
  service = "run.googleapis.com"
}

resource "google_service_account" "fourkeys" {
  account_id   = "fourkeys"
  display_name = "Service Account for Four Keys resources"
}
