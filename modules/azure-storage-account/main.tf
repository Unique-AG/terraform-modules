locals {
  uses_cmk                 = var.customer_managed_key != null
  self_cmk_key             = var.self_cmk_key != null
  store_connection_strings = var.storage_account_connection_string_1 != null && var.storage_account_connection_string_2 != null

}

resource "azurerm_storage_account" "storage_account" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  account_kind             = var.account_kind
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  access_tier              = var.access_tier
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

    dynamic "container_delete_retention_policy" {
      for_each = var.container_deleted_retain_days > 0 ? [1] : []
      content {
        days = var.container_deleted_retain_days
      }
    }

    dynamic "delete_retention_policy" {
      for_each = var.deleted_retain_days > 0 ? [1] : []
      content {
        days                     = var.deleted_retain_days
        permanent_delete_enabled = false
      }
    }
  }

  identity {
    type         = length(var.identity_ids) > 0 ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.identity_ids
  }

  dynamic "network_rules" {
    for_each = var.network_rules != null ? [1] : []
    content {
      default_action             = "Deny"
      virtual_network_subnet_ids = var.network_rules.virtual_network_subnet_ids
      ip_rules                   = var.network_rules.ip_rules
      bypass                     = var.network_rules.bypass

      dynamic "private_link_access" {
        for_each = { for pla in var.network_rules.private_link_accesses : pla.endpoint_resource_id => pla }
        content {
          endpoint_resource_id = private_link_access.value.endpoint_resource_id
          endpoint_tenant_id   = private_link_access.value.endpoint_tenant_id
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      customer_managed_key # acc. to docs 🤷‍♂️
    ]
  }
}

resource "azurerm_storage_container" "container" {
  for_each              = var.containers
  name                  = each.key
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = each.value.access_type
}

resource "azurerm_storage_account_customer_managed_key" "cmk" {
  count                     = local.uses_cmk ? 1 : 0
  storage_account_id        = azurerm_storage_account.storage_account.id
  key_vault_id              = var.customer_managed_key.key_vault_id
  key_name                  = var.customer_managed_key.key_name
  key_version               = var.customer_managed_key.key_version
  user_assigned_identity_id = var.customer_managed_key.user_assigned_identity_id
}

resource "azurerm_storage_management_policy" "default" {
  count              = var.storage_management_policy_default.enabled == true ? 1 : 0
  storage_account_id = azurerm_storage_account.storage_account.id

  rule {
    name    = "default"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
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

# cmk is created if cmk name is provided

resource "azurerm_key_vault_key" "storage-account-byok" {
  count        = local.self_cmk_key ? 1 : 0
  name         = var.self_cmk_key.key_name
  key_vault_id = var.self_cmk_key.key_vault_id
  key_type     = var.self_cmk_key.key_type
  key_size     = var.self_cmk_key.key_size
  key_opts     = var.self_cmk_key.key_opts
}

resource "azurerm_storage_account_customer_managed_key" "storage_account_cmk" {
  count              = local.self_cmk_key ? 1 : 0
  storage_account_id = azurerm_storage_account.storage_account.id
  key_vault_id       = var.self_cmk_key.key_vault_id
  key_name           = azurerm_key_vault_key.storage-account-byok[0].name
  depends_on         = [azurerm_key_vault_key.storage-account-byok[0]]
}

resource "azurerm_key_vault_secret" "storage-account-connection-string-1" {
  count        = local.store_connection_strings ? 1 : 0
  name         = var.storage_account_connection_string_1
  value        = azurerm_storage_account.storage_account.primary_connection_string
  key_vault_id = var.kv_sac_id
}

resource "azurerm_key_vault_secret" "storage-account-connection-string-2" {
  count        = local.store_connection_strings ? 1 : 0
  name         = var.storage_account_connection_string_2
  value        = azurerm_storage_account.storage_account.secondary_connection_string
  key_vault_id = var.kv_sac_id
}