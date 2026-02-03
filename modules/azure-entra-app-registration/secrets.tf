resource "azuread_application_password" "aad_app_password" {
  count          = var.client_secret_generation_config.enabled ? 1 : 0
  application_id = azuread_application.this.id
  display_name   = "unique-enterprise-gitops-app-key"
}

resource "azurerm_key_vault_secret" "aad_app_gitops_client_id" {
  count        = var.client_secret_generation_config.enabled && var.client_secret_generation_config.keyvault_id != null ? 1 : 0
  name         = "aad-app-${var.client_secret_generation_config.secret_name}-client-id"
  value        = azuread_application.this.client_id
  key_vault_id = var.client_secret_generation_config.keyvault_id
}

resource "azurerm_key_vault_secret" "aad_app_gitops_client_secret" {
  count        = var.client_secret_generation_config.enabled && var.client_secret_generation_config.keyvault_id != null ? 1 : 0
  name         = "aad-app-${var.client_secret_generation_config.secret_name}-client-secret"
  value        = azuread_application_password.aad_app_password[0].value
  key_vault_id = var.client_secret_generation_config.keyvault_id
}

output "client_id" {
  description = "The client ID of the Azure AD application."
  value       = azuread_application.this.client_id
}

output "client_secret" {
  description = "The client secret of the Azure AD application."
  sensitive   = true
  value       = var.client_secret_generation_config.enabled && var.client_secret_generation_config.output_enabled ? azuread_application_password.aad_app_password[0].value : null
}
