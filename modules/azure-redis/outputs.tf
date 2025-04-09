output "id" {
  value       = azurerm_redis_cache.arc.id
  description = "The ID of the Redis Cache instance"
}

output "hostname" {
  value       = azurerm_redis_cache.arc.hostname
  description = "The hostname of the Redis Cache instance"
}

output "ssl_port" {
  value       = azurerm_redis_cache.arc.ssl_port
  description = "The SSL port of the Redis Cache instance"
}

output "non_ssl_port" {
  value       = azurerm_redis_cache.arc.port
  description = "The non-SSL port of the Redis Cache instance"
}

output "primary_access_key" {
  value       = azurerm_redis_cache.arc.primary_access_key
  description = "The current primary key that clients can use to authenticate with Redis Cache"
  sensitive   = true
}

output "secondary_access_key" {
  value       = azurerm_redis_cache.arc.secondary_access_key
  description = "The current secondary key that clients can use to authenticate with Redis Cache"
  sensitive   = true
}

output "password_secret_name" {
  description = "Name of the secret containing Redis password"
  value       = var.password_secret_name
}

output "host_secret_name" {
  description = "Name of the secret containing Redis host"
  value       = var.host_secret_name
}

output "port_secret_name" {
  description = "Name of the secret containing Redis port"
  value       = var.port_secret_name
}
