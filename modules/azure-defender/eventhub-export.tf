# This file configures continuous export from Microsoft Defender for Cloud to Event Hub.
# It uses azurerm_security_center_automation to export security alerts, assessments,
# and secure scores to a specified Event Hub.

data "azurerm_eventhub_namespace_authorization_rule" "send" {
  count = var.eventhub_export != null ? 1 : 0

  name                = var.eventhub_export.eventhub.authorization_rule_name
  resource_group_name = var.eventhub_export.eventhub.resource_group_name
  namespace_name      = var.eventhub_export.eventhub.namespace_name
}
data "azurerm_eventhub" "eventhub" {
  name                = var.eventhub_export.eventhub.name
  resource_group_name = var.eventhub_export.eventhub.resource_group_name
  namespace_name      = var.eventhub_export.eventhub.namespace_name
}

resource "azurerm_security_center_automation" "eventhub_export" {
  count = var.eventhub_export != null ? 1 : 0

  name                = var.eventhub_export.name
  location            = var.eventhub_export.location
  resource_group_name = var.eventhub_export.resource_group_name
  scopes              = [var.subscription_id]

  # Export security alerts
  dynamic "source" {
    for_each = var.eventhub_export.export_alerts ? [1] : []
    content {
      event_source = "Alerts"
      dynamic "rule_set" {
        for_each = length(var.eventhub_export.alert_severities) > 0 ? [1] : []
        content {
          dynamic "rule" {
            for_each = var.eventhub_export.alert_severities
            content {
              property_path  = "properties.metadata.severity"
              operator       = "Equals"
              expected_value = rule.value
              property_type  = "String"
            }
          }
        }
      }
    }
  }

  # Export security assessments (recommendations)
  dynamic "source" {
    for_each = var.eventhub_export.export_assessments ? [1] : []
    content {
      event_source = "Assessments"
      dynamic "rule_set" {
        for_each = length(var.eventhub_export.assessment_statuses) > 0 ? [1] : []
        content {
          dynamic "rule" {
            for_each = var.eventhub_export.assessment_statuses
            content {
              property_path  = "properties.status.code"
              operator       = "Equals"
              expected_value = rule.value
              property_type  = "String"
            }
          }
        }
      }
    }
  }

  # Export security secure scores
  dynamic "source" {
    for_each = var.eventhub_export.export_secure_scores ? [1] : []
    content {
      event_source = "SecureScores"
    }
  }

  # Action to send to Event Hub
  action {
    type              = "eventhub"
    resource_id       = data.azurerm_eventhub.eventhub.id
    connection_string = data.azurerm_eventhub_namespace_authorization_rule.send[0].primary_connection_string
  }
}

