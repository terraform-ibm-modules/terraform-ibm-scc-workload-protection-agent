########################################################################################################################
# Outputs
########################################################################################################################

output "id" {
  value       = module.scc_wp_agent.id
  description = "ID of provisioned SCC WP agent."
  sensitive   = true
}

output "name" {
  value       = module.scc_wp_agent.name
  description = "Name of provisioned SCC WP agent."
  sensitive   = true
}
