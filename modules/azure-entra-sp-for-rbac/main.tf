resource "azuread_application" "sp_for_rbac" {
  display_name = var.display_name
}

resource "azuread_service_principal" "sp_for_rbac" {
  client_id = azuread_application.sp_for_rbac.client_id
}

resource "time_rotating" "sp_for_rbac_password" {
  rotation_months = 20
}

resource "azuread_application_password" "sp_for_rbac_password" {
  count          = var.client_secret_generation_config.keyvault_id != null ? 1 : 0
  application_id = azuread_application.sp_for_rbac.id
  display_name   = var.display_name
  rotate_when_changed = {
    rotation = time_rotating.sp_for_rbac_password.id
  }
}
