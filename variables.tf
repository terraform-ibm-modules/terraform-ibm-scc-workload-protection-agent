########################################################################################################################
# Input Variables
########################################################################################################################

variable "name" {
  type        = string
  description = "Helm release name."
}

variable "namespace" {
  type        = string
  description = "Namespace of the Security and Compliance Workload Protection agent."
  default     = "ibm-scc-wp"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name to add Security and Compliance Workload Protection agent to."
}

variable "access_key" {
  type        = string
  description = "Security and Compliance Workload Protection instance access key."
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region where Security and Compliance Workload Protection instance is created."
}

variable "endpoint_type" {
  type        = string
  description = "Specify the endpoint (public and private) for the IBM Cloud Security and Compliance Center Workload Protection service."
  default     = "private"
  validation {
    error_message = "The specified endpoint_type can be private or public only."
    condition     = contains(["private", "public"], var.endpoint_type)
  }
}
