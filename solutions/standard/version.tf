terraform {
  required_version = ">= 1.3.0"

  required_providers {
    # Lock DA into an exact provider version - renovate automation will keep it updated
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.72.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.0"
    }
  }
}
