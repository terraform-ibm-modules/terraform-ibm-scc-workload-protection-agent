########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key to deploy resources."
  sensitive   = true
}
variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}
########################################################################################################################
# SCC Workload Protection Agent variables
########################################################################################################################

variable "name" {
  type        = string
  description = "The Helm release name."
  default     = "ibm-scc-wp-agent"
}

variable "namespace" {
  type        = string
  description = "The namespace of the Workload Protection agent."
  default     = "ibm-scc-wp"
}

variable "existing_cluster_id" {
  type        = string
  description = "The cluster ID to add the Workload Protection agent to."
}

variable "existing_cluster_resource_group_id" {
  type        = string
  description = "The resource group ID of the cluster."
}

variable "access_key" {
  type        = string
  description = "The Workload Protection instance access key."
  sensitive   = true
}

variable "region" {
  type        = string
  description = "The region where the Workload Protection instance is created."
  default     = "us-south"
}

variable "endpoint_type" {
  type        = string
  description = "The endpoint for the Workload Protection service. Possible values: `public`, `private.`"
  default     = "private"
  validation {
    error_message = "The specified endpoint_type can be private or public only."
    condition     = contains(["private", "public"], var.endpoint_type)
  }
}

variable "deployment_tag" {
  type        = string
  description = "A global tag that is included in the components. The tag represents the mechanism where the components are installed. For example, `terraform` or `local`."
  default     = "terraform"
}

variable "kspm_deploy" {
  type        = bool
  description = "Whether to deploy the Workload Protection Kubernetes Security Posture Management component."
  default     = true
}

variable "node_analyzer_deploy" {
  type        = bool
  description = "Whether to deploy the Workload Protection node analyzer component."
  default     = true
}

variable "host_scanner_deploy" {
  type        = bool
  description = "Whether to deploy the Workload Protection host scanner component. Applies only if `node_analyzer_deploy` is true."
  default     = true
}

variable "cluster_scanner_deploy" {
  type        = bool
  description = "Whether to deploy the Workload Protection cluster scanner component."
  default     = true
}

variable "cluster_shield_deploy" {
  type        = bool
  description = "Deploy Cluster Shield component. If enabled, kspm collector and cluster scanner will not be enabled."
  default     = false
}

variable "universal_ebpf" {
  type        = bool
  description = "Deploy Workload Protection agent with universal eBPF enabled. It requires kernel version 5.8+."
  default     = false
}

variable "cluster_endpoint_type" {
  type        = string
  description = "The endpoint for the cluster. Possible values: `public`, `private.`"
  default     = "private"
  validation {
    error_message = "The specified cluster_endpoint_type can be private or public only."
    condition     = contains(["private", "public"], var.cluster_endpoint_type)
  }
}

variable "wait_till" {
  description = "To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, `IngressReady` and `Normal`"
  type        = string
  default     = "Normal"

  validation {
    error_message = "`wait_till` value must be one of `MasterNodeReady`, `OneWorkerNodeReady`, `IngressReady` or `Normal`."
    condition = contains([
      "MasterNodeReady",
      "OneWorkerNodeReady",
      "IngressReady",
      "Normal"
    ], var.wait_till)
  }
}

variable "wait_till_timeout" {
  description = "Timeout for wait_till in minutes."
  type        = number
  default     = 30
}

########################################################################################################################
# SCC Workload Protection agent resource management variables
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

variable "is_vpc_cluster" {
  type        = bool
  description = "Specify true if the target cluster for the DA is a VPC cluster, false if it is classic cluster."
  default     = true
}
