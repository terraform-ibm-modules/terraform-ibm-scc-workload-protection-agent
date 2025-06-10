##############################################################################
# Input Variables
##############################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix for name of all resource created by this example"
  default     = "base-scc-wp"
  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable "region" {
  type        = string
  description = "Region where resources are created"
  default     = "us-south"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "is_openshift" {
  type        = bool
  description = "Defines whether this is an OpenShift or Kubernetes cluster"
  default     = true
}

variable "is_vpc_cluster" {
  type        = bool
  description = "Specify true if the target cluster for the workload protection agents is a VPC cluster, false if it is classic cluster."
  default     = true
}

variable "datacenter" {
  type        = string
  description = "If creating a classic cluster, the data center where the cluster is created"
  default     = "syd01"
}

variable "cluster_scanner_deploy" {
  type        = bool
  description = "Deploy SCC Workload Protection cluster scanner component."
  default     = true
}

variable "kspm_deploy" {
  type        = bool
  description = "Deploy SCC Workload Protection KSPM component."
  default     = true
}

variable "cluster_shield_deploy" {
  type        = bool
  description = "Deploy Cluster Shield component. If enabled, kspm collector and cluster scanner will not be enabled."
  default     = false
}

variable "scc_workload_protection_trusted_profile_name" {
  description = "The name to give the trusted profile that is created by this module if `cspm_enabled` is `true. Must begin with a letter."
  type        = string
  default     = "workload-protection-trusted-profile"
}

##############################################################################
