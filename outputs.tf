########################################################################################################################
# Outputs
########################################################################################################################

output "id" {
  description = "ID of provisioned SCC WP agent."
  value       = resource.helm_release.scc_wp_agent.id
  sensitive   = true

}

output "name" {
  description = "Name of provisioned SCC WP agent."
  value       = resource.helm_release.scc_wp_agent.name
  sensitive   = true
}
