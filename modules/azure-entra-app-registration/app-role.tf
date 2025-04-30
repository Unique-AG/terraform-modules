resource "random_uuid" "maintainers" {}
resource "random_uuid" "application_support" {}
resource "random_uuid" "system_support" {}
resource "random_uuid" "infrastructure_support" {}

resource "azuread_service_principal" "this" {
  client_id                    = azuread_application.this.client_id
  app_role_assignment_required = var.role_assignments_required
}

resource "azuread_application_app_role" "application_support" {
  application_id = azuread_application.this.id
  role_id        = random_uuid.application_support.id

  allowed_member_types = ["User"]
  description          = "Application Support, allows to support the application."
  display_name         = "Application Support"
  value                = "application_support"
}

resource "azuread_app_role_assignment" "application_support" {
  for_each            = setunion(var.application_support_object_ids, var.system_support_object_ids, var.infrastructure_support_object_ids)
  app_role_id         = azuread_application_app_role.application_support.role_id
  principal_object_id = each.value
  resource_object_id  = azuread_service_principal.this.object_id
}

resource "azuread_application_app_role" "system_support" {
  application_id = azuread_application.this.id
  role_id        = random_uuid.system_support.id

  allowed_member_types = ["User"]
  description          = "System Support, allows to support the system around the application."
  display_name         = "System Support"
  value                = "system_support"
}

resource "azuread_app_role_assignment" "system_support" {
  for_each            = setunion(var.system_support_object_ids, var.infrastructure_support_object_ids)
  app_role_id         = azuread_application_app_role.system_support.role_id
  principal_object_id = each.value
  resource_object_id  = azuread_service_principal.this.object_id
}

resource "azuread_application_app_role" "infrastructure_support" {
  application_id = azuread_application.this.id
  role_id        = random_uuid.infrastructure_support.id

  allowed_member_types = ["User"]
  description          = "Infrastructure Support, allows to support the infrastructure of the application."
  display_name         = "Infrastructure Support"
  value                = "infrastructure_support"
}

resource "azuread_app_role_assignment" "infrastructure_support" {
  for_each            = toset(var.infrastructure_support_object_ids)
  app_role_id         = azuread_application_app_role.infrastructure_support.role_id
  principal_object_id = each.value
  resource_object_id  = azuread_service_principal.this.object_id
}

# Legacy support to not break existing SSO configurations on transition, see README.md
# support for this will be removed in 4.0.0
resource "azuread_application_app_role" "maintainers" {
  application_id = azuread_application.this.id
  role_id        = random_uuid.maintainers.id

  allowed_member_types = ["User"]
  description          = "App role for maintainers"
  display_name         = "Maintain"
  value                = "maintain"
}

resource "azuread_app_role_assignment" "maintainers" {
  for_each            = toset(var.application_support_object_ids)
  app_role_id         = azuread_application_app_role.maintainers.role_id
  principal_object_id = each.value
  resource_object_id  = azuread_service_principal.this.object_id
}
