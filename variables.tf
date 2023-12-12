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
  default     = "ibm-scc-wp"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name to add agent to."
}

variable "access_key" {
  type        = string
  description = "Workload Protection instance access key."
  sensitive   = true
}

variable "api_endpoint" {
  type        = string
  description = "Workload Protection instance api endpoint. More info: https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-agent-deploy-openshift-helm#agent-deploy-openshift-helm-install-step3 "

  validation {
    error_message = "Public API endpoint structure should be `region.security-compliance-secure.cloud.ibm.com` while private should be `private.region.security-compliance-secure.cloud.ibm.com`"
    condition     = can(regex("^((private.)?([a-z]*-[a-z]*).security-compliance-secure.cloud.ibm.com)$", var.api_endpoint))
  }
}

variable "ingestion_endpoint" {
  type        = string
  description = "Workload Protection instance ingestion endpoint.  More info: https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-agent-deploy-openshift-helm#agent-deploy-openshift-helm-install-step3"
  validation {
    error_message = "Public ingestion endpoint structure should be `ingest.region.security-compliance-secure.cloud.ibm.com` while private should be `ingest.private.region.security-compliance-secure.cloud.ibm.com`"
    condition     = can(regex("^((ingest.(private.)?)([a-z]*-[a-z]*).security-compliance-secure.cloud.ibm.com)$", var.ingestion_endpoint))
  }
}
