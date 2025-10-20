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
  application_id = azuread_application.sp_for_rbac.id
  display_name   = var.client_secret_generation_config.secret_name
  rotate_when_changed = {
    rotation = time_rotating.sp_for_rbac_password.id
  }
}
