terraform {
  required_version = ">= 1.3.0, < 1.6.0"
  required_providers {
    # Use "greater than or equal to" range in modules
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.59.0, < 2.0.0"
    }
    # tflint-ignore: terraform_unused_required_providers
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8.0"
    }
  }
}
