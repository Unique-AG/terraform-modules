# This file configures continuous export from Microsoft Defender for Cloud to Event Hub.
# It uses azurerm_security_center_automation to export security alerts, assessments,
# and secure scores to a specified Event Hub.

resource "azurerm_security_center_automation" "eventhub_export" {
  count = var.eventhub_export != null ? 1 : 0

  name                = var.eventhub_export.name
  location            = var.eventhub_export.location
  resource_group_name = var.eventhub_export.resource_group_name
  scopes              = [var.subscription_id]

  # Export sources (alerts, assessments, secure scores, etc.)
  dynamic "source" {
    for_each = var.eventhub_export.sources
    content {
      event_source = source.value.event_source
      dynamic "rule_set" {
        for_each = source.value.labels
        content {
          rule {
            property_path  = source.value.property_path
            operator       = "Equals"
            expected_value = rule_set.value
            property_type  = "String"
          }
        }
      }
    }
  }

  # Action to send to Event Hub
  action {
    type              = "eventhub"
    resource_id       = var.eventhub_export.eventhub.id
    connection_string = var.eventhub_export.eventhub.connection_string
  }
}

