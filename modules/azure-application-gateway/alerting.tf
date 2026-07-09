resource "azurerm_monitor_metric_alert" "backend_5xx" {
  count = var.backend_5xx_alert.enabled ? 1 : 0

  name                = "Application Gateway 5xx Error"
  resource_group_name = var.resource_group.name
  scopes              = [azurerm_application_gateway.appgw.id]
  description         = "Alert when backend 5xx errors are above ${var.backend_5xx_alert.threshold} for more than 1 hour"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT1H"
  auto_mitigate       = true

  criteria {
    metric_namespace = "microsoft.network/applicationgateways"
    metric_name      = "BackendResponseStatus"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.backend_5xx_alert.threshold

    dimension {
      name     = "HttpStatusGroup"
      operator = "StartsWith"
      values   = ["5xx"]
    }

    dynamic "dimension" {
      for_each = length(var.backend_5xx_alert.excluded_backend_settings) > 0 ? [1] : []
      content {
        name     = "BackendHttpSetting"
        operator = "Exclude"
        values   = var.backend_5xx_alert.excluded_backend_settings
      }
    }
  }

  dynamic "action" {
    for_each = length(var.backend_5xx_alert.action_group_ids) > 0 ? var.backend_5xx_alert.action_group_ids : var.metric_alerts_external_action_group_ids
    content {
      action_group_id = action.value
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "application_gateway_metric_alerts" {
  for_each = var.metric_alerts

  name                     = each.value.name
  resource_group_name      = var.resource_group.name
  scopes                   = [azurerm_application_gateway.appgw.id]
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
