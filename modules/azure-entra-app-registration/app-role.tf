resource "random_uuid" "maintainers" {}

resource "azuread_application_app_role" "maintainers" {
  application_id = azuread_application.this.id
  role_id        = random_uuid.maintainers.id

  allowed_member_types = ["User"]
  description          = "App role for maintainers"
  display_name         = "Maintain"
  value                = "maintain"
}

resource "azuread_service_principal" "this" {
  client_id = azuread_application.this.client_id
}

resource "azuread_app_role_assignment" "maintainers" {
  for_each            = toset(var.maintainers_principal_object_ids)
  app_role_id         = azuread_application_app_role.maintainers.role_id
  principal_object_id = each.value
  resource_object_id  = azuread_service_principal.this.object_id
}
