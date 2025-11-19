terraform {
  required_version = ">= 1.0"

  required_providers {
    castai = {
      source  = "castai/castai"
      version = ">= 8.1.1"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}