terraform {
  required_version = ">= 1.3.0"
  required_providers {
    # Use "greater than or equal to" range in modules
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8.0, < 3.0.0"
    }
  }
}
