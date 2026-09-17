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

  # Delegated (Scope) permissions grouped by resource app — tenant-wide consent via oauth2PermissionGrant
  delegated_consent_permissions_by_resource = var.admin_consent_enabled ? {
    for resource_app_id, accesses in var.required_resource_access_list :
    resource_app_id => [for access in accesses : access.id if access.type == "Scope"]
    if anytrue([for access in accesses : access.type == "Scope"])
  } : {}

  # Resource APIs needed for delegated permission grants
  resource_app_ids_for_consent = var.admin_consent_enabled ? toset(keys(local.delegated_consent_permissions_by_resource)) : toset([])
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
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
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
# Admin Consent (delegated permissions)
#------------------------------------------------------------------------------

resource "azuread_service_principal" "external_apis" {
  for_each = local.resource_app_ids_for_consent

  client_id    = each.value
  use_existing = true
}

resource "time_sleep" "wait_for_propagation" {
  count = var.admin_consent_enabled && length(local.delegated_consent_permissions_by_resource) > 0 ? 1 : 0

  depends_on      = [azuread_application.this, azuread_service_principal.this]
  create_duration = "30s"
}

#------------------------------------------------------------------------------
# Delegated permission consent (tenant-wide admin consent for Scope)
#------------------------------------------------------------------------------

resource "azuread_service_principal_delegated_permission_grant" "delegated_consent" {
  for_each = local.delegated_consent_permissions_by_resource

  service_principal_object_id          = azuread_service_principal.this.object_id
  resource_service_principal_object_id = azuread_service_principal.external_apis[each.key].object_id

  claim_values = [
    for permission_id in each.value : [
      for scope_name, scope_id in azuread_service_principal.external_apis[each.key].oauth2_permission_scope_ids :
      scope_name if scope_id == permission_id
    ][0]
  ]

  depends_on = [time_sleep.wait_for_propagation]
}

#------------------------------------------------------------------------------
# Client Secret & Key Vault Storage
#------------------------------------------------------------------------------

# Two overlapping secrets (current + previous rotation epoch) so consumers that
# lag behind a rotation (e.g. ExternalSecrets + Argo CD) keep a valid credential
# for a full rotation period. Epochs are anchored to a fixed unix grid, making
# every attribute deterministic per epoch: existing instances never drift.
locals {
  # 730h average month keeps the default validity_hours (17520h) at exactly two rotation periods
  rotation_period_seconds = var.client_secret_generation_config.rotation_months * 2628000
  rotation_now_unix       = provider::time::rfc3339_parse(plantimestamp()).unix
  rotation_epoch          = floor(local.rotation_now_unix / local.rotation_period_seconds)
  # previous epoch is skipped when its end_date is not comfortably in the future (validity_hours < 2 periods)
  rotation_epochs = var.client_secret_generation_config.enabled ? {
    for epoch in [local.rotation_epoch - 1, local.rotation_epoch] :
    formatdate("YYYYMMDD", timeadd("1970-01-01T00:00:00Z", "${epoch * local.rotation_period_seconds}s")) => epoch
    if epoch * local.rotation_period_seconds + var.client_secret_generation_config.validity_hours * 3600 > local.rotation_now_unix + 86400
  } : {}
  rotation_current_key = formatdate("YYYYMMDD", timeadd("1970-01-01T00:00:00Z", "${local.rotation_epoch * local.rotation_period_seconds}s"))
}

resource "azuread_application_password" "aad_app_password" {
  for_each = local.rotation_epochs

  application_id = azuread_application.this.id
  display_name = "${coalesce(
    var.client_secret_generation_config.explicit_password_display_name,
    "${var.client_secret_generation_config.secret_name}-client-secret",
  )}-${each.key}"
  end_date = timeadd("1970-01-01T00:00:00Z", "${each.value * local.rotation_period_seconds + var.client_secret_generation_config.validity_hours * 3600}s")

  rotate_when_changed = {
    keeper = var.client_secret_generation_config.rotation_keeper
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_key_vault_secret" "aad_app_gitops_client_id" {
  count = var.client_secret_generation_config.enabled && var.client_secret_generation_config.keyvault_id != null ? 1 : 0

  name = coalesce(
    var.client_secret_generation_config.explicit_client_id_secret_name,
    "${var.client_secret_generation_config.secret_name}-client-id",
  )
  value        = azuread_application.this.client_id
  key_vault_id = var.client_secret_generation_config.keyvault_id
}

resource "azurerm_key_vault_secret" "aad_app_gitops_client_secret" {
  count = var.client_secret_generation_config.enabled && var.client_secret_generation_config.keyvault_id != null ? 1 : 0

  name = coalesce(
    var.client_secret_generation_config.explicit_client_secret_secret_name,
    "${var.client_secret_generation_config.secret_name}-client-secret",
  )
  value           = azuread_application_password.aad_app_password[local.rotation_current_key].value
  key_vault_id    = var.client_secret_generation_config.keyvault_id
  expiration_date = azuread_application_password.aad_app_password[local.rotation_current_key].end_date
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "aad_app_password_expiry" {
  count = var.client_secret_generation_config.enabled && var.client_secret_generation_config.expiry_alert != null ? 1 : 0

  name = coalesce(
    var.client_secret_generation_config.expiry_alert.name,
    "${var.client_secret_generation_config.secret_name}-expiry",
  )
  resource_group_name = try(var.client_secret_generation_config.expiry_alert.resource_group_name, "")
  location            = try(var.client_secret_generation_config.expiry_alert.location, "")

  description                       = "Entra client secret for ${var.display_name} expires within 30 days. Apply Terraform so time_rotating can replace it."
  enabled                           = true
  evaluation_frequency              = "P1D"
  mute_actions_after_alert_duration = "P2D"
  scopes                            = [try(var.client_secret_generation_config.expiry_alert.log_analytics_workspace_id, "")]
  severity                          = 2
  window_duration                   = "P1D"

  criteria {
    query = <<-QUERY
      print SecretExpiry = datetime(${jsonencode(azuread_application_password.aad_app_password[local.rotation_current_key].end_date)})
      | where now() >= SecretExpiry - 30d
    QUERY

    operator                = "GreaterThan"
    threshold               = 0
    time_aggregation_method = "Count"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = try(var.client_secret_generation_config.expiry_alert.action_group_ids, [])
  }
}
