locals {
  log_analytics_destination_name = coalesce(var.explicit_log_analytics_destination_name, "law")
}

resource "azurerm_monitor_data_collection_rule" "this" {
  name                = var.name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  kind                = "WorkspaceTransforms"
  tags                = var.tags

  destinations {
    log_analytics {
      name                  = local.log_analytics_destination_name
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }

  dynamic "data_flow" {
    for_each = var.transformations
    content {
      destinations  = [local.log_analytics_destination_name]
      streams       = ["Microsoft-Table-${data_flow.key}"]
      transform_kql = trimspace(data_flow.value)
    }
  }

  lifecycle {
    precondition {
      condition     = length(var.transformations) > 0
      error_message = "At least one table transformation is required. Configure transformations."
    }
  }
}
