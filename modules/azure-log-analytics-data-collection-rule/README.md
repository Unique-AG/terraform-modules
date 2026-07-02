# Log Analytics Workspace Transform DCR

Creates an Azure Monitor Data Collection Rule (DCR) with `kind = WorkspaceTransforms` that runs KQL on incoming Log Analytics data before it is stored.

## Usage

Azure applies a workspace-transform DCR only after the workspace references it via `data_collection_rule_id` or `defaultDataCollectionRuleResourceId`.

```hcl
module "law_data_collection_rule" {
  source = "github.com/unique-ag/terraform-modules.git//modules/azure-log-analytics-data-collection-rule?depth=1&ref=azure-log-analytics-data-collection-rule-2.0.0"

  name                       = "dcr-law-${azurerm_log_analytics_workspace.law.name}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  resource_group = {
    name     = azurerm_resource_group.core.name
    location = azurerm_resource_group.core.location
  }

  tags = local.tags
}
```

If the workspace also depends on this module's `dcr_id`, pass a hand-built workspace ARM ID to `log_analytics_workspace_id` to avoid a Terraform dependency cycle.

## Default redaction

By default, the module redacts token-bearing query strings in `AGWAccessLogs.RequestUri`, `RequestQuery`, and `OriginalRequestUriWithArgs`.

Override the default by replacing `transformations`:

```hcl
transformations = {
  AGWAccessLogs = <<-KQL
    source
    | extend RequestQuery = iif(RequestQuery contains "token=", "[Redacted]", RequestQuery)
  KQL
}
```

## Raw transformations

`transformations` is a map of Log Analytics table name to KQL:

```hcl
transformations = {
  LAQueryLogs = "source | where QueryText !contains 'LAQueryLogs'"
}
```

When overriding `transformations`, include every table that needs a transform. Tables without a transform still ingest normally.

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.15 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_data_collection_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_explicit_log_analytics_destination_name"></a> [explicit\_log\_analytics\_destination\_name](#input\_explicit\_log\_analytics\_destination\_name) | Log Analytics destination name when the default is not desired. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | ARM resource ID of the Log Analytics workspace this DCR transforms data for. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Data Collection Rule. | `string` | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resource group where the DCR is deployed. | <pre>object({<br/>    location = string<br/>    name     = string<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the DCR. | `map(string)` | `{}` | no |
| <a name="input_transformations"></a> [transformations](#input\_transformations) | Raw transformKql queries keyed by Log Analytics table name. | `map(string)` | <pre>{<br/>  "AGWAccessLogs": "source\n\| extend RequestUri = iif(RequestUri contains \"token=\" and indexof(RequestUri, \"?\") >= 0, strcat(substring(RequestUri, 0, indexof(RequestUri, \"?\")), \"?[Redacted]\"), RequestUri)\n\| extend RequestQuery = iif(RequestQuery contains \"token=\", \"[Redacted]\", RequestQuery)\n\| extend OriginalRequestUriWithArgs = iif(OriginalRequestUriWithArgs contains \"token=\" and indexof(OriginalRequestUriWithArgs, \"?\") >= 0, strcat(substring(OriginalRequestUriWithArgs, 0, indexof(OriginalRequestUriWithArgs, \"?\")), \"?[Redacted]\"), OriginalRequestUriWithArgs)\n"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_flow_tables"></a> [data\_flow\_tables](#output\_data\_flow\_tables) | Log Analytics table names configured with ingestion-time transformations. |
| <a name="output_dcr_id"></a> [dcr\_id](#output\_dcr\_id) | Resource ID of the Data Collection Rule. |
| <a name="output_dcr_name"></a> [dcr\_name](#output\_dcr\_name) | Name of the Data Collection Rule. |
<!-- END_TF_DOCS -->