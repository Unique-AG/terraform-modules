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
    id_token {
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
      name                  = "groups"
    }
    saml2_token {
      additional_properties = []
      essential             = false
      name                  = "groups"
    }
  }
  lifecycle {
    ignore_changes = [
      app_role,
    ]
  }
}
