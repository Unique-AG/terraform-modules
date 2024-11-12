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

  dynamic "container_delete_retention_policy" {
    for_each = var.storage_management_policy_default.enabled ? [1] : []
    content {
      days = var.storage_management_policy_default.container_deleted_retain_days
    }
  }

  dynamic "delete_retention_policy" {
    for_each = var.storage_management_policy_default.enabled ? [1] : []
    content {
      days                     = var.storage_management_policy_default.deleted_retain_days
      permanent_delete_enabled = false
    }
  }

  dynamic "restore_policy" {
    for_each = var.storage_management_policy_default.enabled ? [1] : []
    content {
      days = var.storage_management_policy_default.restorable_days
    }
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }

  lifecycle {
    ignore_changes = [
      customer_managed_key # acc. to docs 🤷‍♂️
    ]
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

resource "azurerm_storage_management_policy" "default" {
  count              = var.storage_management_policy_default.enabled == true ? 1 : 0
  storage_account_id = azurerm_storage_account.storage_account.id

  rule {
    name    = "default"
    enabled = true
    filters {
      blob_types = ["blockBlob", "appendBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = var.storage_management_policy_default.blob_to_cool_after_last_modified_days
        tier_to_cold_after_days_since_modification_greater_than    = var.storage_management_policy_default.blob_to_cold_after_last_modified_days
        tier_to_archive_after_days_since_modification_greater_than = var.storage_management_policy_default.blob_to_archive_after_last_modified_days
        delete_after_days_since_modification_greater_than          = var.storage_management_policy_default.blob_to_deleted_after_last_modified_days
      }
    }
  }
}
