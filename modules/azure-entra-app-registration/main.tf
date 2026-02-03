#------------------------------------------------------------------------------
# Local Variables
#------------------------------------------------------------------------------

locals {
  # Define cumulative sets for easier role assignment
  infra_support_users  = toset(var.infrastructure_support_object_ids)
  system_support_users = setunion(var.system_support_object_ids, local.infra_support_users)
  app_support_users    = setunion(var.application_support_object_ids, local.system_support_users)
  all_users            = setunion(var.user_object_ids, local.app_support_users)

  # Define app roles attributes
  # UUIDs are manually created via a tool like https://www.uuidgenerator.net/version4
  # Reason: the loop is easier to control and read than using random_uuid
  app_roles_map = {
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

  # Extract all application permissions (Role type) from required_resource_access_list
  # These are the permissions that need admin consent
  admin_consent_permissions = var.admin_consent_enabled ? flatten([
    for resource_app_id, accesses in var.required_resource_access_list : [
      for access in accesses : {
        resource_app_id = resource_app_id
        permission_id   = access.id
      } if access.type == "Role"
    ]
  ]) : []

  # Get unique resource app IDs that have Role permissions
  resource_app_ids_for_consent = var.admin_consent_enabled ? toset([
    for perm in local.admin_consent_permissions : perm.resource_app_id
  ]) : toset([])
}

#------------------------------------------------------------------------------
# Application & Service Principal
#------------------------------------------------------------------------------

resource "azuread_application" "this" {
  display_name          = var.display_name
  sign_in_audience      = var.sign_in_audience
  privacy_statement_url = var.privacy_statement_url
  terms_of_service_url  = var.terms_of_service_url

  owners = var.owner_user_object_ids

  web {
    homepage_url = var.homepage_url
    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
    redirect_uris = var.redirect_uris
  }

  public_client {
    redirect_uris = var.redirect_uris_public_native
  }

  dynamic "required_resource_access" {
    for_each = [for resource_app_id, accesses in var.required_resource_access_list : {
      resource_app_id = resource_app_id
      accesses        = accesses
    }]

    content {
      resource_app_id = required_resource_access.value.resource_app_id

      dynamic "resource_access" {
        for_each = required_resource_access.value.accesses

        content {
          id   = resource_access.value.id
          type = resource_access.value.type
        }
      }
    }
  }

  optional_claims {
    access_token {
      additional_properties = []
      essential             = false
      name                  = "email"
    }
    access_token {
      additional_properties = []
      essential             = false
      name                  = "groups"
    }
    id_token {
      additional_properties = []
      essential             = false
      name                  = "email"
    }
    id_token {
      additional_properties = []
      essential             = false
      name                  = "groups"
    }
    saml2_token {
      additional_properties = []
      essential             = false
      name                  = "groups"
    }
  }

  lifecycle {
    ignore_changes = [app_role]
  }
}

resource "azuread_service_principal" "this" {
  client_id                    = azuread_application.this.client_id
  app_role_assignment_required = var.role_assignments_required
}

#------------------------------------------------------------------------------
# App Roles & Role Assignments
#------------------------------------------------------------------------------

resource "azuread_application_app_role" "managed_roles" {
  for_each = local.app_roles_map

  application_id       = azuread_application.this.id
  role_id              = each.value.role_id
  allowed_member_types = ["User"]
  description          = each.value.description
  display_name         = each.value.display_name
  value                = each.value.value
}

resource "azuread_app_role_assignment" "managed_roles" {
  for_each = {
    for assignment in local.flattened_assignments :
    "${assignment.role_name}:${assignment.principal_id}" => assignment
  }

  app_role_id         = azuread_application_app_role.managed_roles[each.value.role_name].role_id
  principal_object_id = each.value.principal_id
  resource_object_id  = azuread_service_principal.this.object_id
}

#------------------------------------------------------------------------------
# Admin Consent for Application Permissions
#------------------------------------------------------------------------------

resource "azuread_service_principal" "external_apis" {
  for_each = local.resource_app_ids_for_consent

  client_id    = each.value
  use_existing = true
}

resource "time_sleep" "wait_for_propagation" {
  count = var.admin_consent_enabled && length(local.admin_consent_permissions) > 0 ? 1 : 0

  depends_on      = [azuread_application.this, azuread_service_principal.this]
  create_duration = "30s"
}

resource "azuread_app_role_assignment" "admin_consent" {
  for_each = {
    for idx, perm in local.admin_consent_permissions :
    "${perm.resource_app_id}:${perm.permission_id}" => perm
  }

  app_role_id         = each.value.permission_id
  principal_object_id = azuread_service_principal.this.object_id
  resource_object_id  = azuread_service_principal.external_apis[each.value.resource_app_id].object_id

  depends_on = [time_sleep.wait_for_propagation]
}

#------------------------------------------------------------------------------
# Client Secret & Key Vault Storage
#------------------------------------------------------------------------------

resource "azuread_application_password" "aad_app_password" {
  count = var.client_secret_generation_config.enabled ? 1 : 0

  application_id = azuread_application.this.id
  display_name   = "unique-enterprise-gitops-app-key"
}

resource "azurerm_key_vault_secret" "aad_app_gitops_client_id" {
  count = var.client_secret_generation_config.enabled && var.client_secret_generation_config.keyvault_id != null ? 1 : 0

  name         = "aad-app-${var.client_secret_generation_config.secret_name}-client-id"
  value        = azuread_application.this.client_id
  key_vault_id = var.client_secret_generation_config.keyvault_id
}

resource "azurerm_key_vault_secret" "aad_app_gitops_client_secret" {
  count = var.client_secret_generation_config.enabled && var.client_secret_generation_config.keyvault_id != null ? 1 : 0

  name         = "aad-app-${var.client_secret_generation_config.secret_name}-client-secret"
  value        = azuread_application_password.aad_app_password[0].value
  key_vault_id = var.client_secret_generation_config.keyvault_id
}
