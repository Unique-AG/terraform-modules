data "azuread_application_published_app_ids" "well_known" {}

resource "azuread_service_principal" "msgraph" {
  client_id    = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing = true
}

resource "azuread_application" "langfuse" {
  display_name     = var.display_name
  sign_in_audience = var.sign_in_audience

  web {
    homepage_url = var.homepage_url
    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
    redirect_uris = var.redirect_uris
  }

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["profile"] # delegated
      type = "Scope"
    }

    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"] # delegated
      type = "Scope"
    }

    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["openid"] # delegated
      type = "Scope"
    }

    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["email"] # delegated
      type = "Scope"
    }
  }


  optional_claims {
    access_token {
      additional_properties = []
      essential             = true
      name                  = "email"
    }
    id_token {
      additional_properties = []
      essential             = true
      name                  = "email"
    }
  }
  lifecycle {
    ignore_changes = [
      app_role,
    ]
  }
}

resource "azuread_application_password" "langfuse_password" {
  application_id = azuread_application.langfuse.id
  display_name   = var.client_secret_generation_config.secret_name
}

resource "azuread_service_principal" "langfuse" {
  client_id                    = azuread_application.langfuse.client_id
  app_role_assignment_required = var.role_assignments_required
}

resource "azuread_app_role_assignment" "default_access" {
  for_each = var.allowed_groups

  app_role_id         = "00000000-0000-0000-0000-000000000000" # Default role ID 
  principal_object_id = each.value
  resource_object_id  = azuread_service_principal.langfuse.object_id
}

resource "azuread_service_principal_delegated_permission_grant" "msgraph_consent" {
  service_principal_object_id          = azuread_service_principal.langfuse.object_id
  resource_service_principal_object_id = azuread_service_principal.msgraph.object_id
  claim_values                         = ["profile", "User.Read", "openid", "email"]
}