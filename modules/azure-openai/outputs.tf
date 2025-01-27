output "cognitive_account_endpoints" {
  description = "The endpoints used to connect to the Cognitive Service Account."
  value       = { for aca in azurerm_cognitive_account.aca : aca.name => aca.endpoint }
}
output "model_version_endpoints" {
  description = "List of objects containing endpoint, location and list of models"
  value       = jsonencode(local.model_version_endpoints)
}
output "primary_access_keys" {
  description = " A primary access keys which can be used to connect to the Cognitive Service Accounts."
  value       = { for aca in azurerm_cognitive_account.aca : aca.name => aca.primary_access_key }
  sensitive   = true
}
output "endpoints_secret_names" {
  description = "List of secret names containing the endpoints for each Cognitive Service Account. Returns null if Key Vault integration is disabled."
  value       = local.create_vault_secrets ? [for k, v in azurerm_key_vault_secret.endpoint : v.name] : null
}
output "model_version_endpoint_secret_name" {
  description = "Name of the secret containing the model version endpoint definitions. Returns null if Key Vault integration is disabled."
  value       = local.create_vault_secrets ? var.endpoint_definitions_secret_name : null
}
output "keys_secret_names" {
  description = "List of secret names containing the access keys for each Cognitive Service Account. Returns null if Key Vault integration is disabled."
  value       = local.create_vault_secrets ? [for k, v in azurerm_key_vault_secret.key : v.name] : null
}
output "endpoints_secret_names" {
  value = local.create_vault_secrets ? [for k, v in azurerm_key_vault_secret.endpoint : v.name] : null
}
output "model_version_endpoint_secret_name" {
  value = local.create_vault_secrets ? var.endpoint_definitions_secret_name : null
}
output "keys_secret_names" {
  value = local.create_vault_secrets ? [for k, v in azurerm_key_vault_secret.key : v.name] : null
}
