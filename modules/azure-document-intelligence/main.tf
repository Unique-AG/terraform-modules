resource "azurerm_cognitive_account" "aca" {
  for_each                      = var.accounts
  name                          = "${var.doc_intelligence_name}-${each.key}"
  location                      = each.value.location
  resource_group_name           = var.resource_group_name
  kind                          = each.value.account_kind
  sku_name                      = each.value.account_sku_name
  tags                          = var.tags
  public_network_access_enabled = each.value.public_network_access_enabled
  local_auth_enabled            = each.value.local_auth_enabled
  custom_subdomain_name         = each.value.custom_subdomain_name

  dynamic "identity" {
    for_each = each.value.customer_managed_key != null ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [each.value.customer_managed_key.user_assigned_identity.resource_id]
    }
  }

  lifecycle {
    ignore_changes = [customer_managed_key]
  }
}

locals {
  accounts_with_cmk = {
    for k, v in var.accounts : k => v
    if v.customer_managed_key != null
  }

  azure_document_intelligence_endpoints = [
    for key, value in var.accounts : azurerm_cognitive_account.aca[key].endpoint
  ]
  azure_document_intelligence_endpoint_definitions = [
    for key, value in var.accounts : {
      name     = key
      endpoint = azurerm_cognitive_account.aca[key].endpoint
      location = azurerm_cognitive_account.aca[key].location
    }
  ]
}


resource "azurerm_private_endpoint" "pe" {
  for_each            = { for k, v in var.accounts : k => v if try(v.private_endpoint != null, false) }
  name                = "${var.doc_intelligence_name}-${each.key}-pe"
  location            = each.value.private_endpoint.vnet_location != null ? each.value.private_endpoint.vnet_location : each.value.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.private_endpoint.subnet_id

  private_service_connection {
    name                           = "${var.doc_intelligence_name}-${each.key}-psc"
    private_connection_resource_id = azurerm_cognitive_account.aca[each.key].id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [each.value.private_endpoint.private_dns_zone_id]
  }
}

resource "azurerm_cognitive_account_customer_managed_key" "cmk" {
  for_each = local.accounts_with_cmk

  cognitive_account_id = azurerm_cognitive_account.aca[each.key].id
  key_vault_key_id     = each.value.customer_managed_key.key_vault_key_id
  identity_client_id   = each.value.customer_managed_key.user_assigned_identity.client_id
}
