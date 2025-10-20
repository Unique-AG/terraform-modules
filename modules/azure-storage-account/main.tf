locals {
  uses_cmk                 = var.customer_managed_key != null && var.self_cmk == null
  self_cmk                 = var.self_cmk != null && var.customer_managed_key == null
  store_connection_strings = var.connection_settings != null
}

# Random string for unique resource names (only when backup vault is needed)
resource "random_string" "suffix" {
  count   = var.backup_vault != null ? 1 : 0
  length  = 6
  lower   = true
  upper   = false
  special = false
}

resource "azurerm_storage_account" "storage_account" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  account_kind             = var.account_kind
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  access_tier              = var.access_tier
  tags                     = merge(var.tags, var.storage_account_tags)

  # secure by default
  allow_nested_items_to_be_public   = false
  https_traffic_only_enabled        = true
  public_network_access_enabled     = var.public_network_access_enabled
  min_tls_version                   = var.min_tls_version
  shared_access_key_enabled         = var.shared_access_key_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled

  # enable mounting account as disk
  nfsv3_enabled  = var.is_nfs_mountable
  is_hns_enabled = var.is_nfs_mountable

  # enable access from browsers
  blob_properties {
    change_feed_enabled           = var.data_protection_settings.change_feed_retention_days > 0
    change_feed_retention_in_days = var.data_protection_settings.change_feed_retention_days > 0 ? var.data_protection_settings.change_feed_retention_days : null
    versioning_enabled            = var.data_protection_settings.versioning_enabled
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
      for_each = var.data_protection_settings.container_soft_delete_retention_days > 0 ? [1] : []
      content {
        days = var.data_protection_settings.container_soft_delete_retention_days
      }
    }

    dynamic "delete_retention_policy" {
      for_each = var.data_protection_settings.blob_soft_delete_retention_days > 0 ? [1] : []
      content {
        days                     = var.data_protection_settings.blob_soft_delete_retention_days
        permanent_delete_enabled = false
      }
    }
    dynamic "restore_policy" {
      for_each = var.data_protection_settings.point_in_time_restore_days > 0 ? [1] : []
      content {
        days = var.data_protection_settings.point_in_time_restore_days
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
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = each.value.access_type
}

resource "azurerm_private_endpoint" "storage_account_pe" {
  count               = var.private_endpoint != null ? 1 : 0
  name                = "${var.name}-pe"
  location            = coalesce(var.private_endpoint.location, var.location)
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint.subnet_id
  tags                = merge(var.tags, var.private_endpoint.tags)

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    is_manual_connection           = false
    subresource_names              = var.private_endpoint.subresource_names
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_endpoint.private_dns_zone_id]
  }
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
  count              = var.storage_management_policy_default != null ? 1 : 0
  storage_account_id = azurerm_storage_account.storage_account.id

  rule {
    name    = "default"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = var.storage_management_policy_default.blob_to_cool_after_last_modified_days
        tier_to_cold_after_days_since_modification_greater_than = var.storage_management_policy_default.blob_to_cold_after_last_modified_days
        # Archive tier is only supported for LRS, GRS, and RA-GRS replication types
        # It is NOT supported for ZRS, GZRS, or RA-GZRS
        tier_to_archive_after_days_since_modification_greater_than = (
          var.storage_management_policy_default.blob_to_archive_after_last_modified_days != null &&
          contains(["LRS", "GRS", "RA-GRS"], var.account_replication_type)
        ) ? var.storage_management_policy_default.blob_to_archive_after_last_modified_days : null
        delete_after_days_since_modification_greater_than = var.storage_management_policy_default.blob_to_deleted_after_last_modified_days
      }
    }
  }
}

# cmk is created if cmk name is provided

resource "azurerm_key_vault_key" "storage-account-byok" {
  count        = local.self_cmk ? 1 : 0
  name         = var.self_cmk.key_name
  key_vault_id = var.self_cmk.key_vault_id
  key_type     = var.self_cmk.key_type
  key_size     = var.self_cmk.key_size
  key_opts     = var.self_cmk.key_opts
}

resource "azurerm_storage_account_customer_managed_key" "storage_account_cmk" {
  count                     = local.self_cmk ? 1 : 0
  storage_account_id        = azurerm_storage_account.storage_account.id
  key_vault_id              = var.self_cmk.key_vault_id
  key_name                  = azurerm_key_vault_key.storage-account-byok[0].name
  user_assigned_identity_id = var.self_cmk.user_assigned_identity_id
}

resource "azurerm_key_vault_secret" "storage-account-connection-string-1" {
  count           = local.store_connection_strings ? 1 : 0
  name            = var.connection_settings.connection_string_1
  value           = azurerm_storage_account.storage_account.primary_connection_string
  key_vault_id    = var.connection_settings.key_vault_id
  expiration_date = var.connection_settings.expiration_date
}

resource "azurerm_key_vault_secret" "storage-account-connection-string-2" {
  count           = local.store_connection_strings ? 1 : 0
  name            = var.connection_settings.connection_string_2
  value           = azurerm_storage_account.storage_account.secondary_connection_string
  key_vault_id    = var.connection_settings.key_vault_id
  expiration_date = var.connection_settings.expiration_date
}

# Data Protection Backup Vault
resource "azurerm_data_protection_backup_vault" "backup_vault" {
  count                        = var.backup_vault != null ? 1 : 0
  name                         = "${var.backup_vault.name}-${random_string.suffix[0].result}"
  location                     = coalesce(var.backup_vault.location, var.location)
  resource_group_name          = coalesce(var.backup_vault.resource_group_name, var.resource_group_name)
  datastore_type               = var.backup_vault.datastore_type
  redundancy                   = var.backup_vault.redundancy
  cross_region_restore_enabled = var.backup_vault.redundancy == "GeoRedundant" ? var.backup_vault.cross_region_restore_enabled : null
  retention_duration_in_days   = var.backup_vault.retention_duration_in_days
  immutability                 = var.backup_vault.immutability
  soft_delete                  = var.backup_vault.soft_delete
  tags                         = merge(var.tags, var.backup_vault.tags)

  dynamic "identity" {
    for_each = var.backup_vault.identity != null ? [var.backup_vault.identity] : []
    content {
      type = identity.value.type
    }
  }
}

# Role assignment for backup vault to access storage account
resource "azurerm_role_assignment" "backup_vault_storage_access" {
  count                = var.backup_vault != null && var.backup_role_assignment_enabled ? 1 : 0
  scope                = azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Account Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[0].identity[0].principal_id

  depends_on = [
    azurerm_data_protection_backup_vault.backup_vault,
    azurerm_storage_account.storage_account
  ]
}

# Backup Policy for Blob Storage
resource "azurerm_data_protection_backup_policy_blob_storage" "backup_policy" {
  count    = var.backup_vault != null ? 1 : 0
  name     = var.backup_policy.name
  vault_id = azurerm_data_protection_backup_vault.backup_vault[0].id

  operational_default_retention_duration = var.backup_policy.operational_default_retention_duration
  vault_default_retention_duration       = var.backup_policy.vault_default_retention_duration
  backup_repeating_time_intervals        = var.backup_policy.backup_repeating_time_intervals
  time_zone                              = var.backup_policy.time_zone

  dynamic "retention_rule" {
    for_each = var.backup_policy.retention_rules
    content {
      name     = retention_rule.value.name
      priority = retention_rule.value.priority

      criteria {
        absolute_criteria      = retention_rule.value.criteria.absolute_criteria
        days_of_month          = retention_rule.value.criteria.days_of_month
        days_of_week           = retention_rule.value.criteria.days_of_week
        months_of_year         = retention_rule.value.criteria.months_of_year
        scheduled_backup_times = retention_rule.value.criteria.scheduled_backup_times
        weeks_of_month         = retention_rule.value.criteria.weeks_of_month
      }

      life_cycle {
        data_store_type = retention_rule.value.life_cycle.data_store_type
        duration        = retention_rule.value.life_cycle.duration
      }
    }
  }
}

# Backup Instance for Blob Storage
resource "azurerm_data_protection_backup_instance_blob_storage" "backup_instance" {
  count                           = var.backup_vault != null ? 1 : 0
  name                            = var.backup_instance.name
  vault_id                        = azurerm_data_protection_backup_vault.backup_vault[0].id
  location                        = var.location
  storage_account_id              = azurerm_storage_account.storage_account.id
  backup_policy_id                = azurerm_data_protection_backup_policy_blob_storage.backup_policy[0].id
  storage_account_container_names = var.backup_instance.storage_account_container_names
  depends_on = [
    azurerm_data_protection_backup_policy_blob_storage.backup_policy
  ]
}