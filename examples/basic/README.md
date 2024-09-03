# Basic example

An end-to-end basic example that will provision the following:
- A new resource group if one is not passed in.
- A new VPC with single subnet and zone, and public gateway
- A cluster in IBM Cloud
  - It supports IKS and ROKS in both VPC and classic with the variables `is_openshift` and `is_vpc_cluster`
- A new SCC Workload Portection instance
- A new SCC Workload Portection agent
