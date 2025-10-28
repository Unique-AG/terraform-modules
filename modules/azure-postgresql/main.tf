locals {
  uses_cmk = var.customer_managed_key != null && var.self_cmk == null
  self_cmk = var.self_cmk != null && var.customer_managed_key == null
}

resource "azurerm_postgresql_flexible_server" "apfs" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = var.flex_pg_version

  administrator_login    = var.administrator_login
  administrator_password = var.admin_password
  sku_name               = var.flex_sku
  storage_mb             = var.flex_storage_mb
  tags                   = merge(var.tags, var.postgresql_server_tags)
  zone                   = var.zone
  auto_grow_enabled      = var.auto_grow_enabled

  public_network_access_enabled = var.public_network_access_enabled
  backup_retention_days         = var.flex_pg_backup_retention_days

  delegated_subnet_id = var.delegated_subnet_id
  private_dns_zone_id = var.private_dns_zone_id

  dynamic "customer_managed_key" {
    for_each = local.self_cmk ? [1] : []
    content {
      key_vault_key_id                  = azurerm_key_vault_key.psql-account-byok[0].id
      primary_user_assigned_identity_id = var.self_cmk.user_assigned_identity_id
    }
  }

  dynamic "customer_managed_key" {
    for_each = local.uses_cmk ? [1] : []
    content {
      key_vault_key_id                  = var.customer_managed_key.key_vault_key_id
      primary_user_assigned_identity_id = var.customer_managed_key.user_assigned_identity_id
    }
  }

  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  dynamic "timeouts" {
    for_each = length(var.timeouts) > 0 ? [1] : []
    content {
      create = var.timeouts.create
      read   = var.timeouts.read
      update = var.timeouts.update
      delete = var.timeouts.delete
    }
  }
  lifecycle {
    ignore_changes = [zone, storage_mb]
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "parameters" {
  for_each  = var.parameter_values
  server_id = azurerm_postgresql_flexible_server.apfs.id
  name      = each.key
  value     = each.value
}

resource "azurerm_postgresql_flexible_server_database" "destroy_prevented_database" {
  for_each = { for key, val in var.databases :
  key => val if val.prevent_destroy }
  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.apfs.id
  collation = each.value.collation
  charset   = each.value.charset
  lifecycle {
    prevent_destroy = "true"
  }
}

moved {
  from = azurerm_postgresql_flexible_server_database.indestructible_database_server
  to   = azurerm_postgresql_flexible_server_database.destroy_prevented_database
}

resource "azurerm_postgresql_flexible_server_database" "destroyable_database" {
  for_each = { for key, val in var.databases :
  key => val if !val.prevent_destroy }
  name      = each.value.name
  server_id = azurerm_postgresql_flexible_server.apfs.id
  collation = each.value.collation
  charset   = each.value.charset
  lifecycle {
    prevent_destroy = "false"
  }
}

moved {
  from = azurerm_postgresql_flexible_server_database.destructible_database_server
  to   = azurerm_postgresql_flexible_server_database.destroyable_database
}

resource "azurerm_key_vault_key" "psql-account-byok" {
  count        = local.self_cmk ? 1 : 0
  name         = var.self_cmk.key_name
  key_vault_id = var.self_cmk.key_vault_id
  key_type     = var.self_cmk.key_type
  key_size     = var.self_cmk.key_size
  key_opts     = var.self_cmk.key_opts
}

resource "azurerm_monitor_metric_alert" "postgres_metric_alerts" {
  for_each = var.metric_alerts

  name                     = each.value.name
  resource_group_name      = var.resource_group_name
  scopes                   = [azurerm_postgresql_flexible_server.apfs.id]
  description              = each.value.description
  severity                 = each.value.severity
  frequency                = each.value.frequency
  window_size              = each.value.window_size
  enabled                  = each.value.enabled
  auto_mitigate            = each.value.auto_mitigate
  target_resource_type     = each.value.target_resource_type
  target_resource_location = each.value.target_resource_location

  # Static criteria block (conditional)
  dynamic "criteria" {
    for_each = each.value.criteria != null ? [each.value.criteria] : []
    content {
      metric_namespace       = criteria.value.metric_namespace
      metric_name            = criteria.value.metric_name
      aggregation            = criteria.value.aggregation
      operator               = criteria.value.operator
      threshold              = criteria.value.threshold
      skip_metric_validation = criteria.value.skip_metric_validation

      dynamic "dimension" {
        for_each = criteria.value.dimension
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
    }
  }

  # Dynamic criteria block (conditional)
  dynamic "dynamic_criteria" {
    for_each = each.value.dynamic_criteria != null ? [each.value.dynamic_criteria] : []
    content {
      metric_namespace         = dynamic_criteria.value.metric_namespace
      metric_name              = dynamic_criteria.value.metric_name
      aggregation              = dynamic_criteria.value.aggregation
      operator                 = dynamic_criteria.value.operator
      alert_sensitivity        = dynamic_criteria.value.alert_sensitivity
      evaluation_total_count   = dynamic_criteria.value.evaluation_total_count
      evaluation_failure_count = dynamic_criteria.value.evaluation_failure_count
      ignore_data_before       = dynamic_criteria.value.ignore_data_before
      skip_metric_validation   = dynamic_criteria.value.skip_metric_validation

      dynamic "dimension" {
        for_each = dynamic_criteria.value.dimension
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
    }
  }

  # Application Insights web test location availability criteria block (conditional)
  dynamic "application_insights_web_test_location_availability_criteria" {
    for_each = each.value.application_insights_web_test_location_availability_criteria != null ? [each.value.application_insights_web_test_location_availability_criteria] : []
    content {
      web_test_id           = application_insights_web_test_location_availability_criteria.value.web_test_id
      component_id          = application_insights_web_test_location_availability_criteria.value.component_id
      failed_location_count = application_insights_web_test_location_availability_criteria.value.failed_location_count
    }
  }

  # Action blocks for notifications - prefer new actions format, fallback to action_group_ids
  dynamic "action" {
    for_each = length(each.value.actions) > 0 ? each.value.actions : (
      length(each.value.action_group_ids) > 0 ? [
        for action_group_id in each.value.action_group_ids : {
          action_group_id    = action_group_id
          webhook_properties = {}
        }
        ] : [
        for action_group_id in var.metric_alerts_external_action_group_ids : {
          action_group_id    = action_group_id
          webhook_properties = {}
        }
      ]
    )
    content {
      action_group_id    = action.value.action_group_id
      webhook_properties = action.value.webhook_properties
    }
  }

  tags = var.tags
}

resource "azurerm_management_lock" "can_not_delete_server" {
  count      = var.management_lock != null ? 1 : 0
  name       = var.management_lock.name
  scope      = azurerm_postgresql_flexible_server.apfs.id
  lock_level = "CanNotDelete"
  notes      = var.management_lock.notes
  lifecycle {
    prevent_destroy = true
  }
}
