output "cognitive_account_endpoints" {
  description = "The endpoints used to connect to the Cognitive Service Account."
  value       = { for aca in azurerm_cognitive_account.aca : aca.name => aca.endpoint }
}
output "primary_access_keys" {
  description = " A primary access keys which can be used to connect to the Cognitive Service Accounts."
  value       = { for aca in azurerm_cognitive_account.aca : aca.name => aca.primary_access_key }
  sensitive   = true
}
output "model_version_endpoints" {
  description = "List of objects containing endpoint, location and list of models"
  value       = jsonencode(local.model_version_endpoints)
}
output "endpoints_secret_names" {
  value =  local.create_vault_secrets ? [for k, v in azurerm_key_vault_secret.endpoint : v.name] : null
}
output "model_version_endpoint_secret_name" {
  value =  local.create_vault_secrets ? var.endpoint_definitions_secret_name : null
}
output "keys_secret_names" {
    value = local.create_vault_secrets ? [for k, v in azurerm_key_vault_secret.key : v.name] : null
}