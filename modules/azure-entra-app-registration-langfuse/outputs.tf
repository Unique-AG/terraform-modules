output "client_id" {
  description = "The application (client) ID of the Azure AD application"
  value       = azuread_application.langfuse.client_id
}

output "application_id" {
  description = "The application ID (object ID) of the Azure AD application"
  value       = azuread_application.langfuse.id
}

output "client_secret_key_vault_secret_id" {
  description = "The ID of the Key Vault secret containing the client secret"
  value       = var.client_secret_generation_config.keyvault_id != null ? azurerm_key_vault_secret.client_secret[0].id : null
}

output "client_id_key_vault_secret_id" {
  description = "The ID of the Key Vault secret containing the client ID"
  value       = var.client_secret_generation_config.keyvault_id != null ? azurerm_key_vault_secret.client_id[0].id : null
}

