<!-- Update the title -->
# Security and Compliance Center Workload Protection Agent module

<!--
Update status and "latest release" badges:
  1. For the status options, see https://github.ibm.com/GoldenEye/documentation/blob/master/status.md
  2. Update the "latest release" badge to point to the correct module's repo. Replace "module-template" in two places.
-->
[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-scc-workload-protection-agent?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection-agent/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!-- Add a description of module(s) in this repo -->
A module for provisioning an [IBM Cloud Security and Compliance Center Workload Protection agent](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-getting-started). The module uses [sysdig-deploy charts](https://github.com/sysdiglabs/charts/tree/master/charts/sysdig-deploy) which deploys the following components into your cluster:
- Agent
- Node Analyzer
- KSPM Collector

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-scc-workload-protection-agent](#terraform-ibm-scc-workload-protection-agent)
* [Examples](./examples)
    * [Basic example](./examples/basic)
    * [Secure private example](./examples/secure)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and links to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in Authoring Guidelines in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- This heading should always match the name of the root level module (aka the repo name) -->
## terraform-ibm-scc-workload-protection-agent

### Prerequisite
[Security and Compliance Center Workload Protection Instance](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-getting-started#getting-started-step2) must be provision beforehand. Instance can be deployed with [terraform-ibm-scc-workload-protection](https://github.com/terraform-ibm-modules/terraform-ibm-scc-workload-protection) module.

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl
module "scc_wp_agent {
    source             = "terraform-ibm-modules/scc-workload-protection-agent/ibm"
    version            = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
    access_key         = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
    cluster_name       = "example-cluster-name"
    region             = "example-region"
    endpoint_type      = "public"
    name               = "example-name"
}
```

### Required IAM access policies

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the sample Account and IBM Cloud service names and roles with the
information in the console at
Manage > Access (IAM) > Access groups > Access policies.
-->

You need the following permissions to run this module.

- Account Management
    - IAM Services
        - **IBM Cloud Security and Compliance Center Workload Protection** service
            - `Editor` platform access
    - **Kubernetes** service
        - `Viewer` platform access
        - `Manager` service access

<!-- NO PERMISSIONS FOR MODULE
If no permissions are required for the module, uncomment the following
statement instead the previous block.
-->

<!-- No permissions are needed to run this module.-->


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.8.0, < 3.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [helm_release.scc_wp_agent](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | Security and Compliance Workload Protection instance access key. | `string` | n/a | yes |
| <a name="input_agent_limits_cpu"></a> [agent\_limits\_cpu](#input\_agent\_limits\_cpu) | Specifies the CPU limit for the agent. | `string` | `"1"` | no |
| <a name="input_agent_limits_memory"></a> [agent\_limits\_memory](#input\_agent\_limits\_memory) | Specifies the memory limit for the agent. | `string` | `"1024Mi"` | no |
| <a name="input_agent_requests_cpu"></a> [agent\_requests\_cpu](#input\_agent\_requests\_cpu) | Specifies the CPU requested to run in a node for the agent. | `string` | `"1"` | no |
| <a name="input_agent_requests_memory"></a> [agent\_requests\_memory](#input\_agent\_requests\_memory) | Specifies the memory requested to run in a node for the agent. | `string` | `"1024Mi"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name to add Security and Compliance Workload Protection agent to. | `string` | n/a | yes |
| <a name="input_cluster_scanner_deploy"></a> [cluster\_scanner\_deploy](#input\_cluster\_scanner\_deploy) | Deploy SCC Workload Protection cluster scanner component. | `bool` | `true` | no |
| <a name="input_cluster_scanner_imagesbomextractor_limits_cpu"></a> [cluster\_scanner\_imagesbomextractor\_limits\_cpu](#input\_cluster\_scanner\_imagesbomextractor\_limits\_cpu) | Specifies the CPU limit for the image SBOM Extractor that runs on the cluster scanner. | `string` | `"1"` | no |
| <a name="input_cluster_scanner_imagesbomextractor_limits_memory"></a> [cluster\_scanner\_imagesbomextractor\_limits\_memory](#input\_cluster\_scanner\_imagesbomextractor\_limits\_memory) | Specifies the memory limit for the image SBOM Extractor that runs on the cluster scanner. | `string` | `"350Mi"` | no |
| <a name="input_cluster_scanner_imagesbomextractor_requests_cpu"></a> [cluster\_scanner\_imagesbomextractor\_requests\_cpu](#input\_cluster\_scanner\_imagesbomextractor\_requests\_cpu) | Specifies the CPU requested to run in a node for the image SBOM Extractor that runs on the cluster scanner. | `string` | `"350m"` | no |
| <a name="input_cluster_scanner_imagesbomextractor_requests_memory"></a> [cluster\_scanner\_imagesbomextractor\_requests\_memory](#input\_cluster\_scanner\_imagesbomextractor\_requests\_memory) | Specifies the memory requested to run in a node for the image SBOM Extractor that runs on the cluster scanner. | `string` | `"350Mi"` | no |
| <a name="input_cluster_scanner_runtimestatusintegrator_limits_cpu"></a> [cluster\_scanner\_runtimestatusintegrator\_limits\_cpu](#input\_cluster\_scanner\_runtimestatusintegrator\_limits\_cpu) | Specifies the CPU limit for the runtime status integrator that runs on the cluster scanner. | `string` | `"1"` | no |
| <a name="input_cluster_scanner_runtimestatusintegrator_limits_memory"></a> [cluster\_scanner\_runtimestatusintegrator\_limits\_memory](#input\_cluster\_scanner\_runtimestatusintegrator\_limits\_memory) | Specifies the memory limit for the runtime status integrator that runs on the cluster scanner. | `string` | `"350Mi"` | no |
| <a name="input_cluster_scanner_runtimestatusintegrator_requests_cpu"></a> [cluster\_scanner\_runtimestatusintegrator\_requests\_cpu](#input\_cluster\_scanner\_runtimestatusintegrator\_requests\_cpu) | Specifies the CPU requested to run in a node for the runtime status integrator that runs on the cluster scanner. | `string` | `"350m"` | no |
| <a name="input_cluster_scanner_runtimestatusintegrator_requests_memory"></a> [cluster\_scanner\_runtimestatusintegrator\_requests\_memory](#input\_cluster\_scanner\_runtimestatusintegrator\_requests\_memory) | Specifies the memory requested to run in a node for the runtime status integrator that runs on the cluster scanner. | `string` | `"350Mi"` | no |
| <a name="input_deployment_tag"></a> [deployment\_tag](#input\_deployment\_tag) | Sets a global tag that will be included in the components. It represents the mechanism from where the components have been installed (terraform, local...). | `string` | `"terraform"` | no |
| <a name="input_endpoint_type"></a> [endpoint\_type](#input\_endpoint\_type) | Specify the endpoint (public or private) for the IBM Cloud Security and Compliance Center Workload Protection service. | `string` | `"private"` | no |
| <a name="input_host_scanner_deploy"></a> [host\_scanner\_deploy](#input\_host\_scanner\_deploy) | Deploy SCC Workload Protection host scanner component. If node\_analyzer\_deploy false, this component will not be deployed. | `bool` | `true` | no |
| <a name="input_host_scanner_limits_cpu"></a> [host\_scanner\_limits\_cpu](#input\_host\_scanner\_limits\_cpu) | Specifies the CPU limit for the host scanner that runs on the node analyzer. | `string` | `"500m"` | no |
| <a name="input_host_scanner_limits_memory"></a> [host\_scanner\_limits\_memory](#input\_host\_scanner\_limits\_memory) | Specifies the memory limit for the host scanner that runs on the node analyzer. | `string` | `"1Gi"` | no |
| <a name="input_host_scanner_requests_cpu"></a> [host\_scanner\_requests\_cpu](#input\_host\_scanner\_requests\_cpu) | Specifies the CPU requested to run in a node for the host scanner that runs on the node analyzer. | `string` | `"150m"` | no |
| <a name="input_host_scanner_requests_memory"></a> [host\_scanner\_requests\_memory](#input\_host\_scanner\_requests\_memory) | Specifies the memory requested to run in a node for the host scanner that runs on the node analyzer. | `string` | `"512Mi"` | no |
| <a name="input_kspm_analyzer_limits_cpu"></a> [kspm\_analyzer\_limits\_cpu](#input\_kspm\_analyzer\_limits\_cpu) | Specifies the CPU limit for the kspm analyzer that runs on the node analyzer. | `string` | `"500m"` | no |
| <a name="input_kspm_analyzer_limits_memory"></a> [kspm\_analyzer\_limits\_memory](#input\_kspm\_analyzer\_limits\_memory) | Specifies the memory limit for the kspm analyzer that runs on the node analyzer. | `string` | `"1536Mi"` | no |
| <a name="input_kspm_analyzer_requests_cpu"></a> [kspm\_analyzer\_requests\_cpu](#input\_kspm\_analyzer\_requests\_cpu) | Specifies the CPU requested to run in a node for the kspm analyzer that runs on the node analyzer. | `string` | `"150m"` | no |
| <a name="input_kspm_analyzer_requests_memory"></a> [kspm\_analyzer\_requests\_memory](#input\_kspm\_analyzer\_requests\_memory) | Specifies the memory requested to run in a node for the kspm analyzer that runs on the node analyzer. | `string` | `"256Mi"` | no |
| <a name="input_kspm_collector_limits_cpu"></a> [kspm\_collector\_limits\_cpu](#input\_kspm\_collector\_limits\_cpu) | Specifies the CPU limit for the kspm collector. | `string` | `"500m"` | no |
| <a name="input_kspm_collector_limits_memory"></a> [kspm\_collector\_limits\_memory](#input\_kspm\_collector\_limits\_memory) | Specifies the memory limit for the kspm collector. | `string` | `"1536Mi"` | no |
| <a name="input_kspm_collector_requests_cpu"></a> [kspm\_collector\_requests\_cpu](#input\_kspm\_collector\_requests\_cpu) | Specifies the CPU requested to run in a node for the kspm collector. | `string` | `"150m"` | no |
| <a name="input_kspm_collector_requests_memory"></a> [kspm\_collector\_requests\_memory](#input\_kspm\_collector\_requests\_memory) | Specifies the memory requested to run in a node for the kspm collector. | `string` | `"256Mi"` | no |
| <a name="input_kspm_deploy"></a> [kspm\_deploy](#input\_kspm\_deploy) | Deploy SCC Workload Protection KSPM component. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Helm release name. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace of the Security and Compliance Workload Protection agent. | `string` | `"ibm-scc-wp"` | no |
| <a name="input_node_analyzer_deploy"></a> [node\_analyzer\_deploy](#input\_node\_analyzer\_deploy) | Deploy SCC Workload Protection node analyzer component. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where Security and Compliance Workload Protection instance is created. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | Helm chart release name. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
