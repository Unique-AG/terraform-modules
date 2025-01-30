output "routeid" {
  value       = azurerm_redis_cache.arc.id
  description = "The Route ID"
}
output "hostname" {
  value       = azurerm_redis_cache.arc.hostname
  description = "The Hostname of the Redis Instance"
}
output "ssl_port" {
  value       = azurerm_redis_cache.arc.ssl_port
  description = "The SSL Port of the Redis Instance"
}
output "non_ssl_port" {
  value       = azurerm_redis_cache.arc.port
  description = "The non-SSL Port of the Redis Instance"
}

output "primary_access_key" {
  value       = azurerm_redis_cache.arc.primary_access_key
  description = "The current primary key that clients can use to authenticate with Redis cache. "
  sensitive   = true
}

output "secondary_access_key" {
  value       = azurerm_redis_cache.arc.secondary_access_key
  description = "The current secondary key that clients can use to authenticate with Redis cache. "
  sensitive   = true
}

output "redis_cache_password_secret_name" {
  description = "Name of the secret containing Redis password."
  value       = local.create_vault_secrets ? local.password_secret_name : null
}

output "redis_cache_host_secret_name" {
  description = "Name of the secret containing Redis host."
  value       = local.create_vault_secrets ? local.host_secret_name : null
}

output "redis_cache_port_secret_name" {
  description = "Name of the secret containing Redis port."
  value       = local.create_vault_secrets ? local.port_secret_name : null
}
