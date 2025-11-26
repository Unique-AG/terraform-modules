locals {
  activity_log_alerts = { for k, v in var.alerts : k => v if v.activity_log_criteria != null }
  metric_alerts       = { for k, v in var.alerts : k => v if v.metric_criteria != null }

  # Convert default action group IDs to action objects for fallback
  default_actions = [for id in var.default_action_group_ids : { action_group_id = id, webhook_properties = {} }]
}

resource "azurerm_monitor_activity_log_alert" "this" {
  for_each = local.activity_log_alerts

  name                = "${var.cluster_name}-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_kubernetes_cluster.cluster.id]
  description         = each.value.description
  enabled             = each.value.enabled
  location            = "global"
  tags                = var.tags

  criteria {
    resource_id    = azurerm_kubernetes_cluster.cluster.id
    operation_name = each.value.activity_log_criteria.operation_name
    category       = each.value.activity_log_criteria.category
    levels         = each.value.activity_log_criteria.levels
    statuses       = each.value.activity_log_criteria.statuses
  }

  dynamic "action" {
    for_each = coalesce(each.value.actions, local.default_actions)
    content {
      action_group_id    = action.value.action_group_id
      webhook_properties = action.value.webhook_properties
    }
  }
}

resource "azurerm_monitor_metric_alert" "this" {
  for_each = local.metric_alerts

  name                = "${var.cluster_name}-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_kubernetes_cluster.cluster.id]
  description         = each.value.description
  severity            = each.value.severity
  frequency           = each.value.frequency
  window_size         = each.value.window_size
  enabled             = each.value.enabled
  tags                = var.tags

  criteria {
    metric_namespace       = each.value.metric_criteria.metric_namespace
    metric_name            = each.value.metric_criteria.metric_name
    aggregation            = each.value.metric_criteria.aggregation
    operator               = each.value.metric_criteria.operator
    threshold              = each.value.metric_criteria.threshold
    skip_metric_validation = each.value.metric_criteria.skip_metric_validation

    dynamic "dimension" {
      for_each = each.value.metric_criteria.dimension
      content {
        name     = dimension.value.name
        operator = dimension.value.operator
        values   = dimension.value.values
      }
    }
  }

  dynamic "action" {
    for_each = coalesce(each.value.actions, local.default_actions)
    content {
      action_group_id    = action.value.action_group_id
      webhook_properties = action.value.webhook_properties
    }
  }
}
