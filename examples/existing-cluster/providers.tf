terraform {
  required_version = ">= 1.0"

  required_providers {
    castai = {
      source  = "castai/castai"
      version = ">= 8.29.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.region
}

provider "castai" {
  api_token = var.castai_api_token
  api_url   = var.castai_api_url
}
