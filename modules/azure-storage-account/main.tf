locals {
  uses_cmk = var.customer_managed_key != null
}

resource "azurerm_storage_account" "storage_account" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  account_kind             = var.account_kind
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  tags                     = var.tags

  # secure by default
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true
  min_tls_version                 = var.min_tls_version

  # enable mounting account as disk
  nfsv3_enabled  = var.is_nfs_mountable
  is_hns_enabled = var.is_nfs_mountable

  # enable access from browsers
  blob_properties {
    dynamic "cors_rule" {
      for_each = var.cors_rules
      content {
        allowed_origins    = cors_rule.value.allowed_origins
        allowed_methods    = cors_rule.value.allowed_methods
        allowed_headers    = cors_rule.value.allowed_headers
        exposed_headers    = cors_rule.value.exposed_headers
        max_age_in_seconds = cors_rule.value.max_age_in_seconds
      }
    }
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }

  lifecycle {
    ignore_changes = local.uses_cmk ? [
      customer_managed_key
    ] : []
  }
}

resource "azurerm_storage_account_customer_managed_key" "cmk" {
  count              = local.uses_cmk ? 1 : 0
  storage_account_id = azurerm_storage_account.storage_account.id
  # Accordig to our design principles we expect that not always the same principals to run 'perimeter' and 'workloads' terraform and thus must fall back to the full URI
  # Docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key#key_vault_id-3
  key_vault_uri = var.customer_managed_key.key_vault_uri
  key_name      = var.customer_managed_key.key_name
  key_version   = var.customer_managed_key.key_version
}
