terraform {
  required_version = ">= 0.12"

  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
