<!-- Update the title -->
# Security and Compliance Center Workload Protection Agent module

<!--
Update status and "latest release" badges:
  1. For the status options, see https://github.ibm.com/GoldenEye/documentation/blob/master/status.md
  2. Update the "latest release" badge to point to the correct module's repo. Replace "module-template" in two places.
-->
[![Incubating (Not yet consumable)](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
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

### Known limitations

The SCC Workload Protection Agent module has the following limitations:

- SCC WPA can not be used inside private VPC, because it uses `public` and `private` endpoints only, while private VPC uses `direct` endpoint. Therefore, to use SCC WPA with VPC, the public gateway must be attached to a subnet.


### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl
    source                    = "terraform-ibm-modules/scc-workload-protection-agent/ibm"
    version                   = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
    cluster_id                = "xxXXxxXXXxXXXXX"
    access_key                = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
    cluster_resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
    api_endpoint              = "<region>.security-compliance-secure.cloud.ibm.com"
    ingestion_endpoint        = "private.<region>.security-compliance-secure.cloud.ibm.com"
    name                      = "ingest.<region>.security-compliance-secure.cloud.ibm.com"
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

<!--
You need the following permissions to run this module.

- Account Management
    - **Sample Account Service** service
        - `Editor` platform access
        - `Manager` service access
    - IAM Services
        - **Sample Cloud Service** service
            - `Administrator` platform access
-->

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, < 1.6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.8.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.59.0, < 2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [helm_release.scc_wp_agent](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [ibm_container_vpc_cluster.cluster](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/container_vpc_cluster) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | Workload Protection instance access key. | `string` | `null` | no |
| <a name="input_api_endpoint"></a> [api\_endpoint](#input\_api\_endpoint) | Workload Protection instance api endpoint. | `string` | n/a | yes |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | Cluster id to add agent to. | `string` | n/a | yes |
| <a name="input_cluster_resource_group_id"></a> [cluster\_resource\_group\_id](#input\_cluster\_resource\_group\_id) | Resource group of the cluster | `string` | n/a | yes |
| <a name="input_ingestion_endpoint"></a> [ingestion\_endpoint](#input\_ingestion\_endpoint) | Workload Protection instance ingestion endpoint. | `string` | n/a | yes |
| <a name="input_is_private_endpoint"></a> [is\_private\_endpoint](#input\_is\_private\_endpoint) | Do you want to use private endpoint | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the workload protection agent. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace of the workload protection agent. | `string` | `"ibm-observe"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of provisioned SCC WP agent. |
| <a name="output_name"></a> [name](#output\_name) | Name of provisioned SCC WP agent. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
