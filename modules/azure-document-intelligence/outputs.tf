output "primary_access_keys" {
  description = "The primary access key of the Cognitive Services Account"
  value       = { for aca in azurerm_cognitive_account.aca : aca.name => aca.primary_access_key }
  sensitive   = true
}
output "azure_document_intelligence_endpoints" {
  description = "Object containing list of endpoints"
  value       = jsonencode(local.azure_document_intelligence_endpoints)
}
output "azure_document_intelligence_endpoint_definitions" {
  description = "Object containing list of objects containing endpoint definitions with name, endpoint and location"
  value       = jsonencode(local.azure_document_intelligence_endpoint_definitions)
}
output "endpoint_definitions_secret_name" {
  description = "Name of the secret containing the list of objects containing endpoint definitions with name, endpoint and location (content of `azure_document_intelligence_endpoint_definitions` output). Returns null if Key Vault integration is disabled"
  value       = local.create_vault_secrets ? var.endpoint_definitions_secret_name : null
}
output "endpoints_secret_name" {
  description = "Name of the secret containing the list of endpoints. Returns null if Key Vault integration is disabled"
  value       = local.create_vault_secrets ? var.endpoints_secret_name : null
}
output "keys_secret_names" {
  description = "List of names of the secrets containing the primary access key to connect to the endpoints. Returns null if Key Vault integration is disabled"
  value       = local.create_vault_secrets ? [for k, v in azurerm_key_vault_secret.key : v.name] : null
}
output "cognitive_account_resource" {
  description = "The properties of the Cognitive Services Account."
  value       = azurerm_cognitive_account.aca
}
