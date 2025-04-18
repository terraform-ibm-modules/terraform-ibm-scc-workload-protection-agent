output "access_key" {
  description = "Workload Protection instance access key."
  value       = module.scc_wp_instance.access_key
  sensitive   = true
}

output "cluster_id" {
  value       = module.ocp_base.cluster_id
  description = "ID of the cluster."
}

output "resource_group_id" {
  value       = module.resource_group.resource_group_id
  description = "Resource group ID"
}
