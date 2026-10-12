locals {
  project_name     = "Unique Apps"
  application_name = "Standalone Apps"

  frontend_paths = ["/chat", "/admin", "/knowledge-upload", "/theme"]
  derived_frontend_uris = [
    for path in local.frontend_paths : "${trimsuffix(var.frontend_base_url, "/")}${path}"
  ]
  redirect_uris             = length(var.redirect_uris) > 0 ? var.redirect_uris : local.derived_frontend_uris
  post_logout_redirect_uris = length(var.post_logout_redirect_uris) > 0 ? var.post_logout_redirect_uris : local.derived_frontend_uris

  root_org_ids   = data.zitadel_organizations.root.ids
  root_org_id    = try(local.root_org_ids[0], "")
  target_org_ids = data.zitadel_organizations.target.ids
}

data "zitadel_organizations" "root" {
  name        = var.root_org_name
  name_method = "TEXT_QUERY_METHOD_EQUALS_IGNORE_CASE"
}

data "zitadel_organizations" "target" {
  name        = var.target_org_name
  name_method = "TEXT_QUERY_METHOD_EQUALS_IGNORE_CASE"
}

resource "terraform_data" "bootstrap_guard" {
  input = {
    root_org_id = local.root_org_id
  }

  lifecycle {
    precondition {
      condition     = length(local.root_org_ids) == 1
      error_message = "Exactly one organization named '${var.root_org_name}' is required."
    }
    precondition {
      condition     = length(local.target_org_ids) <= 1
      error_message = "At most one organization named '${var.target_org_name}' may exist."
    }
    precondition {
      condition     = alltrue([for user in values(var.human_users) : length(setsubtract(user.roles, var.project_roles)) == 0])
      error_message = "Every human_users[*].roles entry must be one of project_roles."
    }
    precondition {
      condition     = length(var.human_users) == 0 || var.human_users_initial_password != null
      error_message = "human_users_initial_password is required when human_users is not empty."
    }
  }
}

resource "zitadel_project" "unique_apps" {
  name                   = local.project_name
  org_id                 = local.root_org_id
  project_role_assertion = true
  project_role_check     = true
  has_project_check      = true

  depends_on = [terraform_data.bootstrap_guard]
}

resource "zitadel_project_role" "unique_apps" {
  for_each = var.project_roles

  org_id       = local.root_org_id
  project_id   = zitadel_project.unique_apps.id
  role_key     = each.value
  display_name = each.value
  group        = "default"
}

resource "zitadel_application_oidc" "standalone_apps" {
  org_id                    = local.root_org_id
  project_id                = zitadel_project.unique_apps.id
  name                      = local.application_name
  redirect_uris             = local.redirect_uris
  post_logout_redirect_uris = local.post_logout_redirect_uris

  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_NONE"
  version                     = "OIDC_VERSION_1_0"
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN"]
  clock_skew                  = "0s"
  dev_mode                    = var.oidc_dev_mode
  access_token_type           = "OIDC_TOKEN_TYPE_JWT"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
}

resource "zitadel_org" "target" {
  name = var.target_org_name

  depends_on = [terraform_data.bootstrap_guard]
}

resource "zitadel_project_grant" "target" {
  org_id         = local.root_org_id
  project_id     = zitadel_project.unique_apps.id
  granted_org_id = zitadel_org.target.id
  role_keys      = var.project_roles

  depends_on = [zitadel_project_role.unique_apps]
}

# The provider's ZITADEL 3.x fallback rejects custom user IDs, so user_id stays unset.
resource "zitadel_machine_user" "scope_management" {
  org_id            = local.root_org_id
  user_name         = var.scope_management_user_name
  name              = "Scope Management Service"
  description       = "JWT service account for node-scope-management."
  access_token_type = "ACCESS_TOKEN_TYPE_JWT"
  with_secret       = false

  depends_on = [terraform_data.bootstrap_guard]
}

resource "zitadel_instance_member" "scope_management" {
  user_id = zitadel_machine_user.scope_management.id
  roles   = ["IAM_OWNER"]
}

resource "zitadel_personal_access_token" "scope_management" {
  org_id          = local.root_org_id
  user_id         = zitadel_machine_user.scope_management.id
  expiration_date = var.scope_management_pat_expiration_date

  depends_on = [zitadel_instance_member.scope_management]
}

resource "zitadel_human_user" "this" {
  for_each = var.human_users

  org_id                       = zitadel_org.target.id
  user_name                    = each.key
  first_name                   = each.value.first_name
  last_name                    = each.value.last_name
  email                        = each.value.email
  is_email_verified            = true
  initial_password             = var.human_users_initial_password
  initial_skip_password_change = true
}

resource "zitadel_user_grant" "this" {
  for_each = { for name, user in var.human_users : name => user if length(user.roles) > 0 }

  org_id           = zitadel_org.target.id
  user_id          = zitadel_human_user.this[each.key].id
  project_id       = zitadel_project.unique_apps.id
  project_grant_id = zitadel_project_grant.target.id
  role_keys        = each.value.roles
}
