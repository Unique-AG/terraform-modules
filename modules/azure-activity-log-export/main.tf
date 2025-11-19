data "azurerm_eventhub_namespace_authorization_rule" "send" {
  name                = var.eventhub.authorization_rule_name
  resource_group_name = var.eventhub.resource_group_name
  namespace_name      = var.eventhub.namespace_name
}


resource "azurerm_monitor_diagnostic_setting" "activity_log_export" {
  name                           = var.name
  target_resource_id             = "/subscriptions/${var.subscription_id}"
  eventhub_authorization_rule_id = data.azurerm_eventhub_namespace_authorization_rule.send.id
  eventhub_name                  = var.eventhub.name

  dynamic "enabled_log" {
    for_each = var.categories
    content {
      category = enabled_log.value
    }
  }
}

