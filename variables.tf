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
  description = "Specify the endpoint (public or private) for the IBM Cloud Security and Compliance Center Workload Protection service."
  default     = "private"
  validation {
    error_message = "The specified endpoint_type can be private or public only."
    condition     = contains(["private", "public"], var.endpoint_type)
  }
}

variable "node_analyzer_deploy" {
  type        = bool
  description = "Deploy SCC Workload Protection node analyzer component."
  default     = true
}

variable "host_scanner_deploy" {
  type        = bool
  description = "Deploy SCC Workload Protection host scanner component. If node_analyzer_deploy false, this component will not be deployed."
  default     = true
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

variable "deployment_tag" {
  type        = string
  description = "Sets a global tag that will be included in the components. It represents the mechanism from where the components have been installed (terraform, local...)."
  default     = "terraform"
}

########################################################################################################################
# Resource Management Variables
########################################################################################################################

variable "agent_requests_cpu" {
  type        = string
  description = "Specifies the CPU requested to run in a node for the agent."
  default     = "1"
}

variable "agent_requests_memory" {
  type        = string
  description = "Specifies the memory requested to run in a node for the agent."
  default     = "1024Mi"
}

variable "agent_limits_cpu" {
  type        = string
  description = "Specifies the CPU limit for the agent."
  default     = "1"
}

variable "agent_limits_memory" {
  type        = string
  description = "Specifies the memory limit for the agent."
  default     = "1024Mi"
}

variable "kspm_collector_requests_cpu" {
  type        = string
  description = "Specifies the CPU requested to run in a node for the kspm collector."
  default     = "150m"
}

variable "kspm_collector_requests_memory" {
  type        = string
  description = "Specifies the memory requested to run in a node for the kspm collector."
  default     = "256Mi"
}

variable "kspm_collector_limits_cpu" {
  type        = string
  description = "Specifies the CPU limit for the kspm collector."
  default     = "500m"
}

variable "kspm_collector_limits_memory" {
  type        = string
  description = "Specifies the memory limit for the kspm collector."
  default     = "1536Mi"
}

variable "kspm_analyzer_requests_cpu" {
  type        = string
  description = "Specifies the CPU requested to run in a node for the kspm analyzer that runs on the node analyzer."
  default     = "150m"
}

variable "kspm_analyzer_requests_memory" {
  type        = string
  description = "Specifies the memory requested to run in a node for the kspm analyzer that runs on the node analyzer."
  default     = "256Mi"
}

variable "kspm_analyzer_limits_cpu" {
  type        = string
  description = "Specifies the CPU limit for the kspm analyzer that runs on the node analyzer."
  default     = "500m"
}

variable "kspm_analyzer_limits_memory" {
  type        = string
  description = "Specifies the memory limit for the kspm analyzer that runs on the node analyzer."
  default     = "1536Mi"
}

variable "host_scanner_requests_cpu" {
  type        = string
  description = "Specifies the CPU requested to run in a node for the host scanner that runs on the node analyzer."
  default     = "150m"
}

variable "host_scanner_requests_memory" {
  type        = string
  description = "Specifies the memory requested to run in a node for the host scanner that runs on the node analyzer."
  default     = "512Mi"
}

variable "host_scanner_limits_cpu" {
  type        = string
  description = "Specifies the CPU limit for the host scanner that runs on the node analyzer."
  default     = "500m"
}

variable "host_scanner_limits_memory" {
  type        = string
  description = "Specifies the memory limit for the host scanner that runs on the node analyzer."
  default     = "1Gi"
}

variable "cluster_scanner_runtimestatusintegrator_requests_cpu" {
  type        = string
  description = "Specifies the CPU requested to run in a node for the runtime status integrator that runs on the cluster scanner."
  default     = "350m"
}

variable "cluster_scanner_runtimestatusintegrator_requests_memory" {
  type        = string
  description = "Specifies the memory requested to run in a node for the runtime status integrator that runs on the cluster scanner."
  default     = "350Mi"
}

variable "cluster_scanner_runtimestatusintegrator_limits_cpu" {
  type        = string
  description = "Specifies the CPU limit for the runtime status integrator that runs on the cluster scanner."
  default     = "1"
}

variable "cluster_scanner_runtimestatusintegrator_limits_memory" {
  type        = string
  description = "Specifies the memory limit for the runtime status integrator that runs on the cluster scanner."
  default     = "350Mi"
}

variable "cluster_scanner_imagesbomextractor_requests_cpu" {
  type        = string
  description = "Specifies the CPU requested to run in a node for the image SBOM Extractor that runs on the cluster scanner."
  default     = "350m"
}

variable "cluster_scanner_imagesbomextractor_requests_memory" {
  type        = string
  description = "Specifies the memory requested to run in a node for the image SBOM Extractor that runs on the cluster scanner."
  default     = "350Mi"
}

variable "cluster_scanner_imagesbomextractor_limits_cpu" {
  type        = string
  description = "Specifies the CPU limit for the image SBOM Extractor that runs on the cluster scanner."
  default     = "1"
}

variable "cluster_scanner_imagesbomextractor_limits_memory" {
  type        = string
  description = "Specifies the memory limit for the image SBOM Extractor that runs on the cluster scanner."
  default     = "350Mi"
}

variable "admission_controller_enabled" {
  type        = bool
  description = "Enables Kubernetes audit logging detections with Falco rules via Admission Controller. If set to true, admission_controller_token is mandatory."
  default     = false
}

variable "admission_controller_kspm_enabled" {
  type        = bool
  description = "Enables Kubernetes Security Posture Management admission controller for scanning new deployed resources for Posture validation. If set to true, you need to enable admission_controller_enabled and define admission_controller_token."
  default     = false
}

variable "admission_controller_token" {
  type        = string
  description = "Token for Admission Controller"
  default     = null
  sensitive   = true
}
