locals {
  # Define cumulative sets for easier role assignment
  infra_support_users  = toset(var.infrastructure_support_object_ids)
  system_support_users = setunion(var.system_support_object_ids, local.infra_support_users)
  app_support_users    = setunion(var.application_support_object_ids, local.system_support_users)
  all_users            = setunion(var.user_object_ids, local.app_support_users)

  # Define app roles attributes
  app_roles_map = {
    # the UUIDs are manually created via a tool like https://www.uuidgenerator.net/version4
    # reason: the loop is way easier to control and read this way than to use random_uuid
    user = {
      role_id      = "6a902661-cfac-44f4-846c-bc5ceaa012d4"
      description  = "User, allows to use the application or login without any additional permissions."
      display_name = "User"
      value        = "user"
    }
    application_support = {
      role_id      = "719570d9-6707-40f4-9193-29ae0745392e"
      description  = "Application Support, allows to support the application."
      display_name = "Application Support"
      value        = "application_support"
    }
    system_support = {
      role_id      = "8719acef-9791-41e4-9621-92d05315181c"
      description  = "System Support, allows to support the system around the application."
      display_name = "System Support"
      value        = "system_support"
    }
    infrastructure_support = {
      role_id      = "0a7f4e66-4942-4a2e-a433-82e54464f116"
      description  = "Infrastructure Support, allows to support the infrastructure of the application."
      display_name = "Infrastructure Support"
      value        = "infrastructure_support"
    }
  }

  # Map roles to their corresponding principal sets
  role_assignment_sets = {
    user                   = local.all_users
    application_support    = local.app_support_users
    system_support         = local.system_support_users
    infrastructure_support = local.infra_support_users
  }

  # Flatten the assignments for use in for_each
  flattened_assignments = flatten([
    for role_name, principal_ids in local.role_assignment_sets : [
      for principal_id in principal_ids : {
        role_name    = role_name
        principal_id = principal_id
      }
    ]
  ])
}

resource "azuread_service_principal" "this" {
  client_id                    = azuread_application.this.client_id
  app_role_assignment_required = var.role_assignments_required
}

# Create app roles using for_each
resource "azuread_application_app_role" "managed_roles" {
  for_each       = local.app_roles_map
  application_id = azuread_application.this.id
  role_id        = each.value.role_id

  allowed_member_types = ["User"]
  description          = each.value.description
  display_name         = each.value.display_name
  value                = each.value.value
}

# Create app role assignments using for_each
resource "azuread_app_role_assignment" "managed_roles" {
  # Create a unique key for each role-principal pair
  for_each = { for assignment in local.flattened_assignments : "${assignment.role_name}:${assignment.principal_id}" => assignment }

  app_role_id         = azuread_application_app_role.managed_roles[each.value.role_name].role_id
  principal_object_id = each.value.principal_id
  resource_object_id  = azuread_service_principal.this.object_id
}

# ------------------------------------------------------------------------------------
# Legacy support to not break existing SSO configurations on transition, see README.md
# support for this will be removed in 4.0.0
resource "random_uuid" "maintainers" {}
resource "azuread_application_app_role" "maintainers" {
  application_id = azuread_application.this.id
  role_id        = random_uuid.maintainers.id

  allowed_member_types = ["User"]
  description          = "App role for maintainers"
  display_name         = "Maintain"
  value                = "maintain"
}
resource "azuread_app_role_assignment" "maintainers" {
  for_each            = toset(var.application_support_object_ids) # Keep legacy assignment logic
  app_role_id         = azuread_application_app_role.maintainers.role_id
  principal_object_id = each.value
  resource_object_id  = azuread_service_principal.this.object_id
}
