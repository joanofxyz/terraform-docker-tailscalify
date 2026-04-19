output "container_name" {
  description = "name of the created container"
  value       = local.container_name
}

output "network_name" {
  description = "name of the tailscale network created for the container"
  value       = local.network_name
}

output "container_network_alias" {
  description = "alias of the container in the tailscale network"
  value       = local.container_network_alias
}
