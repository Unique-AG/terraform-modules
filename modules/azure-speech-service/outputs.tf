output "primary_access_keys" {
  description = "The primary access key of the Cognitive Services Account"
  value       = { for aca in azurerm_cognitive_account.aca : aca.name => aca.primary_access_key }
  sensitive   = true
}
output "azure_speech_service_endpoints" {
  description = "Object containing list of endpoints"
  value       = jsonencode(local.azure_speech_service_endpoints)
}
output "azure_speech_service_endpoint_definitions" {
  description = "Object containing list of objects containing endpoint definitions with name, endpoint and location"
  value       = jsonencode(local.azure_speech_service_endpoint_definitions)
}
output "endpoint_definitions_secret_name" {
  description = "Name of the secret containing the list of objects containing endpoint definitions with name, endpoint and location (content of `azure_speech_service_endpoint_definitions` output). Returns null if Key Vault integration is disabled"
  value       = var.endpoint_definitions_secret_name
}
output "endpoints_secret_name" {
  description = "Name of the secret containing the list of endpoints. Returns null if Key Vault integration is disabled"
  value       = var.endpoints_secret_name
}
output "keys_secret_names" {
  description = "List of names of the secrets containing the primary access key to connect to the endpoints. Returns null if Key Vault integration is disabled"
  value       = [for k, v in azurerm_key_vault_secret.key : v.name]
}
output "cognitive_account_ids" {
  description = "Resource IDs of the Cognitive Services Accounts"
  value       = { for k, v in azurerm_cognitive_account.aca : k => v.id }
}

output "speech_service_secret_names" {
  description = "The names of the Key Vault secrets containing the Speech Service resource IDs"
  value = [
    for account_key in keys(var.accounts) :
    "${account_key}${var.resource_id_secret_name_suffix}"
  ]
}

output "fqdn_secret_names" {
  description = "The names of the Key Vault secrets containing the Speech Service FQDNs"
  value = [
    for account_key in keys(var.accounts) :
    "${account_key}${var.fqdn_secret_name_suffix}"
  ]
}