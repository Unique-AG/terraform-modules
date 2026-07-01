# Azure Log Analytics Data Collection Rule

Creates an Azure Monitor Data Collection Rule (DCR) with `kind = WorkspaceTransforms` that runs KQL on incoming Log Analytics data before it is stored.

## Prerequisites

- Contributor on the resource group hosting the DCR
- Contributor on the Log Analytics workspace
- Diagnostic settings (or other non-DCR ingestion) sending Application Gateway access logs to `AzureDiagnostics`

## Workspace DCR linking

This DCR has no effect until the workspace references it via `data_collection_rule_id` (`defaultDataCollectionRuleResourceId` in Azure).

**Terraform cycle:** if the DCR's `workspace_resource_id` is `azurerm_log_analytics_workspace.law.id` and the workspace sets `data_collection_rule_id = module.*.dcr_id`, Terraform reports a dependency cycle.

Pass a **hand-built workspace ARM ID** into this module's `log_analytics_workspace_id`. Only wire the workspace → DCR direction through Terraform:

```hcl
locals {
  law_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${data.azurerm_resource_group.core.name}/providers/Microsoft.OperationalInsights/workspaces/law-${var.tenant_name}-${var.tenant_environment}"
}

resource "azurerm_log_analytics_workspace" "law" {
  name                        = "law-${var.tenant_name}-${var.tenant_environment}"
  location                    = data.azurerm_resource_group.core.location
  resource_group_name         = data.azurerm_resource_group.core.name
  sku                         = "PerGB2018"
  retention_in_days           = 90
  data_collection_rule_id     = module.law_data_collection_rule.dcr_id
}

module "law_data_collection_rule" {
  source = "github.com/unique-ag/terraform-modules.git//modules/azure-log-analytics-data-collection-rule?depth=1&ref=azure-log-analytics-data-collection-rule-1.0.0"

  log_analytics_workspace_id = local.law_id
  resource_group = {
    name     = data.azurerm_resource_group.core.name
    location = data.azurerm_resource_group.core.location
  }
  workspace_name = "law-${var.tenant_name}-${var.tenant_environment}"
  tags         = local.tags
}
```

Only one workspace DCR may exist per workspace. Additional table transforms belong in the same DCR via `transformations` or `redact_query_string_parameters`.

## Default redaction

With no overrides, the module redacts matching query parameters in `AzureDiagnostics.requestQuery_s` when `Category == "ApplicationGatewayAccessLog"`, producing values like `token=[Redacted]`.

Disable by setting `redact_query_string_parameters = {}` and supplying custom `transformations`, or extend defaults:

```hcl
redact_query_string_parameters = {
  AzureDiagnostics = {
    query_column    = "requestQuery_s"
    category_filter = "ApplicationGatewayAccessLog"
    parameter_names = ["token", "access_token", "code"]
  }
}
```

## Raw transformations

For tables or logic not covered by `redact_query_string_parameters`:

```hcl
transformations = {
  LAQueryLogs = "source | where QueryText !contains 'LAQueryLogs'"
}
```

A table name must not appear in both `redact_query_string_parameters` and `transformations`.

## References

- [Transformations in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/data-collection/data-collection-transformations)
- [Workspace transformation DCR tutorial](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/tutorial-workspace-transformations-api)
- [UN-12652](https://unique-ch.atlassian.net/browse/UN-12652)


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.15 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.79.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_data_collection_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_explicit_name"></a> [explicit\_name](#input\_explicit\_name) | Name for the DCR when the default is not desired. | `string` | `null` | no |
| <a name="input_log_analytics_destination_name"></a> [log\_analytics\_destination\_name](#input\_log\_analytics\_destination\_name) | Destination name referenced by data flows. Must match the destinations.log\_analytics name block. | `string` | `"law"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | ARM resource ID of the Log Analytics workspace this DCR transforms data for.<br/><br/>When the same workspace sets `data_collection_rule_id` to this module's `dcr_id`, pass a<br/>hand-built ARM ID string here (subscription + resource group + workspace name). Do not pass<br/>`azurerm_log_analytics_workspace.*.id` directly or Terraform will report a dependency cycle. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for naming the DCR when explicit\_name is not set. | `string` | `"dcr-law"` | no |
| <a name="input_redact_query_string_parameters"></a> [redact\_query\_string\_parameters](#input\_redact\_query\_string\_parameters) | Per-table configuration for redacting sensitive query-string parameters before ingestion.<br/>Keys are Log Analytics table names (for example AzureDiagnostics). Generates a transformKql<br/>data flow per key unless the same table is defined in `transformations`. | <pre>map(object({<br/>    category_filter = optional(string)<br/>    parameter_names = list(string)<br/>    query_column    = string<br/>    redacted_value  = optional(string, "[Redacted]")<br/>  }))</pre> | <pre>{<br/>  "AzureDiagnostics": {<br/>    "category_filter": "ApplicationGatewayAccessLog",<br/>    "parameter_names": [<br/>      "token"<br/>    ],<br/>    "query_column": "requestQuery_s"<br/>  }<br/>}</pre> | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resource group where the DCR is deployed. | <pre>object({<br/>    location = string<br/>    name     = string<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the DCR. | `map(string)` | `{}` | no |
| <a name="input_transformations"></a> [transformations](#input\_transformations) | Raw transformKql queries keyed by Log Analytics table name. Use for cases not covered by<br/>redact\_query\_string\_parameters. A table key must not appear in both variables. | `map(string)` | `{}` | no |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Log Analytics workspace name. Used only for the default DCR name when explicit\_name is null. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_flow_tables"></a> [data\_flow\_tables](#output\_data\_flow\_tables) | Log Analytics table names configured with ingestion-time transformations. |
| <a name="output_dcr_id"></a> [dcr\_id](#output\_dcr\_id) | Resource ID of the Data Collection Rule. |
| <a name="output_dcr_name"></a> [dcr\_name](#output\_dcr\_name) | Name of the Data Collection Rule. |
<!-- END_TF_DOCS -->