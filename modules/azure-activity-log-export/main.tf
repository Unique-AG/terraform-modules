resource "azurerm_monitor_diagnostic_setting" "activity_log_export" {
  name                           = var.name
  target_resource_id             = var.subscription_id
  eventhub_authorization_rule_id = var.eventhub.authorization_rule_id
  eventhub_name                  = var.eventhub.name

  dynamic "enabled_log" {
    for_each = var.categories
    content {
      category = enabled_log.value
    }
  }
}

