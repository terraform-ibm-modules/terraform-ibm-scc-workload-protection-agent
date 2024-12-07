output "access_key" {
  description = "Workload Protection instance access key."
  value       = module.scc_wp_instance.access_key
  sensitive   = true
}

output "cluster_data" {
  value       = module.landing_zone.cluster_data
  description = "Details of OCP cluster."
}

output "workload_cluster_id" {
  value       = module.landing_zone.workload_cluster_id
  description = "ID of the workload cluster."
}

output "workload_cluster_name" {
  value       = module.landing_zone.workload_cluster_name
  description = "Name of the workload cluster."
}

output "cluster_resource_group_id" {
  value       = module.landing_zone.cluster_data["${var.prefix}-workload-cluster"].resource_group_id
  description = "Resource group ID of the workload cluster."
}
