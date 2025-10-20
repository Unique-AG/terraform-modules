output "client_id" {
  description = "The client ID of the underlying Azure Entra App Registration."
  value       = azuread_application.sp_for_rbac.client_id
}

output "object_id" {
  description = "The object ID of the matching Service Principal to be used for effective role assignments."
  value       = azuread_service_principal.sp_for_rbac.object_id
}

output "client_id_key_vault_secret_id" {
  description = "The ID of the Key Vault secret containing the client ID."
  value       = var.client_secret_generation_config.keyvault_id != null ? azurerm_key_vault_secret.client_id[0].id : null
}

output "client_secret_key_vault_secret_id" {
  description = "The ID of the Key Vault secret containing the client secret."
  value       = var.client_secret_generation_config.keyvault_id != null ? azurerm_key_vault_secret.client_secret[0].id : null
}
