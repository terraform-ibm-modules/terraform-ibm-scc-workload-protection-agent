########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The API Key to use for IBM Cloud."
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this solution."
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable"
  default     = null
}

variable "region" {
  type        = string
  default     = "us-south"
  description = "The region in which to provision SCC resources."
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "app_config_crn" {
  description = "The CRN of an existing App Config instance to use with the SCC Workload Protection instance. Required if `cspm_enabled` is true. NOTE: Ensure the App Config instance has configuration aggregator enabled."
  type        = string
  default     = null
}
