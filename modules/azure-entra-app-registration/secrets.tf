resource "azuread_application_password" "aad_app_password" {
  application_id = azuread_application.this.id
  display_name   = "unique-enterprise-gitops-app-key"
}

resource "azurerm_key_vault_secret" "aad_app_gitops_client_id" {
  name         = "aad-app-${var.aad-app-secret-display-name}-client-id"
  value        = azuread_application.this.client_id
  key_vault_id = var.keyvault_id
}

resource "azurerm_key_vault_secret" "aad_app_gitops_client_secret" {
  name         = "aad-app-${var.aad-app-secret-display-name}-client-secret"
  value        = azuread_application_password.aad_app_password.value
  key_vault_id = var.keyvault_id
}
