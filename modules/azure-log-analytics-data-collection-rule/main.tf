locals {
  dcr_name = (
    var.explicit_name != null
    ? var.explicit_name
    : (
      var.workspace_name != null
      ? "${var.name_prefix}-${var.workspace_name}"
      : var.name_prefix
    )
  )

  redact_condition = {
    for table, cfg in var.redact_query_string_parameters :
    table => (
      cfg.category_filter != null
      ? format("Category == \"%s\" and isnotempty(%s)", cfg.category_filter, cfg.query_column)
      : format("isnotempty(%s)", cfg.query_column)
    )
  }

  redact_replace_pattern = {
    for table, cfg in var.redact_query_string_parameters :
    table => format(
      "@\"(?i)(^|[?&])(%s)=[^&]*\"",
      join("|", cfg.parameter_names)
    )
  }

  redact_replace_replacement = {
    for table, cfg in var.redact_query_string_parameters :
    table => format("@\"\\1\\2=%s\"", cfg.redacted_value)
  }

  generated_transformations = {
    for table, cfg in var.redact_query_string_parameters :
    table => <<-EOT
      source
      | extend ${cfg.query_column} = iif(
          ${local.redact_condition[table]},
          replace_regex(${cfg.query_column}, ${local.redact_replace_pattern[table]}, ${local.redact_replace_replacement[table]}),
          ${cfg.query_column}
        )
    EOT
  }

  data_flow_transformations = merge(local.generated_transformations, var.transformations)
}

resource "azurerm_monitor_data_collection_rule" "this" {
  name                = local.dcr_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  kind                = "WorkspaceTransforms"
  tags                = var.tags

  destinations {
    log_analytics {
      name                  = var.log_analytics_destination_name
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }

  dynamic "data_flow" {
    for_each = local.data_flow_transformations
    content {
      destinations = [var.log_analytics_destination_name]
      streams      = ["Microsoft-Table-${data_flow.key}"]
      transform_kql = trimspace(replace(
        data_flow.value,
        "\n",
        " "
      ))
    }
  }

  lifecycle {
    precondition {
      condition     = length(local.data_flow_transformations) > 0
      error_message = "At least one table transformation is required. Configure redact_query_string_parameters or transformations."
    }
  }
}
