########################################################################################################################
# Input Variables
########################################################################################################################

variable "name" {
  type        = string
  description = "Name of the workload protection agent."
}

variable "namespace" {
  type        = string
  description = "Namespace of the workload protection agent."
  default     = "ibm-observe"
}

variable "cluster_id" {
  type        = string
  description = "Cluster id to add agent to."
}

variable "cluster_resource_group_id" {
  type        = string
  description = "Resource group of the cluster"
}

variable "access_key" {
  type        = string
  description = "Workload Protection instance access key."
  sensitive   = true
  default     = null
}

variable "is_private_endpoint" {
  type        = bool
  description = "Do you want to use private endpoint"
  default     = true
}

variable "api_endpoint" {
  type        = string
  description = "Workload Protection instance api endpoint."
}

variable "ingestion_endpoint" {
  type        = string
  description = "Workload Protection instance ingestion endpoint."
}
