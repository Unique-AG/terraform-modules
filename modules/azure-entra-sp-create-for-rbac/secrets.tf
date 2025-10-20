resource "azurerm_key_vault_secret" "client_id" {
  count           = var.client_secret_generation_config.keyvault_id != null ? 1 : 0
  name            = "${var.client_secret_generation_config.secret_name}-client-id"
  value           = azuread_application.sp_for_rbac.client_id
  key_vault_id    = var.client_secret_generation_config.keyvault_id
  expiration_date = var.client_secret_generation_config.expiration_date
  content_type    = "text/plain"
}

resource "azurerm_key_vault_secret" "client_secret" {
  count           = var.client_secret_generation_config.keyvault_id != null ? 1 : 0
  name            = "${var.client_secret_generation_config.secret_name}-client-secret"
  value           = azuread_application_password.sp_for_rbac_password.value
  key_vault_id    = var.client_secret_generation_config.keyvault_id
  expiration_date = var.client_secret_generation_config.expiration_date
  content_type    = "text/plain"
}
