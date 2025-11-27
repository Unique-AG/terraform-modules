locals {
  # Filter alerts by type
  activity_log_alerts = { for k, v in var.alerts : k => v if v.activity_log_criteria != null }
  metric_alerts       = { for k, v in var.alerts : k => v if v.metric_criteria != null }

  # Get nodepool capacity alert config (there should be at most one)
  nodepool_capacity_alerts = { for k, v in var.alerts : k => v if v.nodepool_capacity_criteria != null }
  nodepool_capacity_config = length(local.nodepool_capacity_alerts) > 0 ? values(local.nodepool_capacity_alerts)[0] : null

  # Convert default action group IDs to action objects for fallback
  default_actions = [for id in coalesce(var.default_action_group_ids, []) : { action_group_id = id, webhook_properties = {} }]

  # Build node pool capacity info for metric alerts
  # Include default pool and additional node pools
  node_pool_capacity = local.nodepool_capacity_config != null && local.nodepool_capacity_config.enabled ? merge(
    {
      default = {
        max_count = var.kubernetes_default_node_count_max
      }
    },
    { for name, pool in var.node_pool_settings : name => {
      max_count = pool.max_count
    } if pool.max_count != null }
  ) : {}
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

# Metric alert for node pool max capacity
# Fires when node count in a pool equals max_count for that pool
# Uses node name pattern: aks-{poolname}-* to filter by pool
resource "azurerm_monitor_metric_alert" "nodepool_at_max_capacity" {
  for_each = local.node_pool_capacity

  name                = "${var.cluster_name}-nodepool-${each.key}-at-max-capacity"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_kubernetes_cluster.cluster.id]
  description         = coalesce(local.nodepool_capacity_config.description, "Alerts when node pool '${each.key}' is running at maximum capacity (${each.value.max_count} nodes)")
  severity            = local.nodepool_capacity_config.severity
  frequency           = local.nodepool_capacity_config.frequency
  window_size         = local.nodepool_capacity_config.window_size
  enabled             = local.nodepool_capacity_config.enabled
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "kube_node_status_condition"
    aggregation      = "Total"
    operator         = "GreaterThanOrEqual"
    threshold        = each.value.max_count

    dimension {
      name     = "status"
      operator = "Include"
      values   = ["true"]
    }

    dimension {
      name     = "status2"
      operator = "Include"
      values   = ["Ready"]
    }

    dimension {
      name     = "node"
      operator = "StartsWith"
      values   = ["aks-${each.key}-"]
    }
  }

  dynamic "action" {
    for_each = coalesce(local.nodepool_capacity_config.actions, local.default_actions)
    content {
      action_group_id    = action.value.action_group_id
      webhook_properties = action.value.webhook_properties
    }
  }
}
