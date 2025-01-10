resource "azurerm_cognitive_account" "aca" {
  for_each              = var.accounts
  name                  = "${var.doc_intelligence_name}-${each.key}"
  location              = each.value.location
  resource_group_name   = var.resource_group_name
  kind                  = each.value.account_kind
  sku_name              = each.value.account_sku_name
  tags                  = var.tags
  custom_subdomain_name = each.value.custom_subdomain_name
  dynamic "identity" {
    for_each = var.user_assigned_identity_ids
    content {
      type         = "UserAssigned"
      identity_ids = [identity.value]
    }
  }
}

locals {
  azure_document_intelligence_endpoints = {
    for key, value in var.accounts : key => azurerm_cognitive_account.aca[key].endpoint
  }
  azure_document_intelligence_endpoint_definitions = {
    for key, value in var.accounts : key => {
      endpoint = azurerm_cognitive_account.aca[key].endpoint
      location = azurerm_cognitive_account.aca[key].location
    }
  }
}
