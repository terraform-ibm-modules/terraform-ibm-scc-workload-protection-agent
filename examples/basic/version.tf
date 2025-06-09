terraform {
  required_version = ">=1.9.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.79.0, < 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8.0, < 3.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.1, < 3.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}
