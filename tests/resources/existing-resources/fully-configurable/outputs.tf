output "access_key" {
  description = "Workload Protection instance access key."
  value       = module.scc_wp_instance.access_key
  sensitive   = true
}

output "cluster_name" {
  value       = module.ocp_base.cluster_name
  description = "Name of the cluster."
}

output "resource_group_id" {
  value       = module.resource_group.resource_group_id
  description = "Resource group ID"
}
