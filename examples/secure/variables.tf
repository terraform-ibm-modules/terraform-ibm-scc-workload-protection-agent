##############################################################################
# Input Variables
##############################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud api token"
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix for name of all resource created by this example"
  default     = "secure-scc-wp"
  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable "region" {
  type        = string
  description = "Region where resources are created"
  default     = "eu-gb"
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

variable "access_tags" {
  type        = list(string)
  description = "Optional list of access management tags to be added to the created resources."
  default     = []
}

variable "app_config_crn" {
  description = "The CRN of an existing App Config instance to use with the SCC Workload Protection instance. Required if `cspm_enabled` is true. NOTE: Ensure the App Config instance has configuration aggregator enabled."
  type        = string
  default     = null
}

variable "scc_workload_protection_trusted_profile_name" {
  description = "The name to give the trusted profile that is created by this module if `cspm_enabled` is `true. Must begin with a letter."
  type        = string
  default     = "wp-trusted-profile-secure"
}

##############################################################################
