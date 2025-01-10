
output "postgresql_server_id" {
  description = "The ID of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.apfs.id
}

output "postgresql_server_fqdn" {
  description = "The FQDN of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.apfs.fqdn
}


output "host_secret_name" {
  description = "The name of the secret containing the hostname"
  value = local.create_vault_secrets ? local.host_secret_name : null
}
output "port_secret_name" {
  description = "The name of the secret containing the port"
  value = local.create_vault_secrets ? local.port_secret_name : null

}
output "username_secret_name" {
  description = "The name of the secret containing the admin username"
  value = local.create_vault_secrets ? local.username_secret_name : null

}
output "password_secret_name" {
  description = "The name of the secret containing the admin password"
  value = local.create_vault_secrets ? local.password_secret_name : null
  
}
output "database_connection_strings_secret_name" {
  description = "The names of the secrets containing the full connection strings to the databases, including the admin username and password"
  value       = local.create_vault_secrets ? { for db in var.databases : db.name => "${var.database_connection_string_secret_prefix}${db.name}" } : null
}