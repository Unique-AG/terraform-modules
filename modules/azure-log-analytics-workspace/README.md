# Log Analytics Workspace

Creates one Azure Log Analytics workspace with a workspace-transform Data Collection Rule (DCR) and default Basic-plan tables.

## Usage

### Default tenant LAW

Default tenant configuration. `ContainerLogV2` and `AKSControlPlane` are configured as Basic-plan tables, while the workspace-transform DCR is created and attached by default. DCR transformation errors are sent to the workspace's `DCRLogErrors` table.

```hcl
module "law" {
  source = "github.com/unique-ag/terraform-modules.git//modules/azure-log-analytics-workspace?depth=1&ref=azure-log-analytics-workspace-1.2.0"

  name                = "uq-${var.tenant_name}-${var.tenant_environment}"
  location            = data.azurerm_resource_group.rg_core.location
  resource_group_name = data.azurerm_resource_group.rg_core.name
  tags                = local.tags
}
```

### Override Basic tables

```hcl
module "law" {
  source = "github.com/unique-ag/terraform-modules.git//modules/azure-log-analytics-workspace?depth=1&ref=azure-log-analytics-workspace-1.2.0"

  name                = "law-example-prod"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  retention_in_days   = 90
  tags                = local.tags

  basic_log_tables = {}
}
```

## Default redaction

By default, the DCR redacts query strings containing `token=`, `key=`, or `code=` in `AGWAccessLogs.RequestUri`, `RequestQuery`, and `OriginalRequestUriWithArgs`. Override `data_collection_rule.transformations` to replace that default:

```hcl
data_collection_rule = {
  transformations = {
    AGWAccessLogs = <<-KQL
      source
      | extend RequestQuery = iif(RequestQuery contains "token=", "[Redacted]", RequestQuery)
    KQL
  }
}
```

## Raw transformations

`data_collection_rule.transformations` is a map of Log Analytics table name to KQL:

```hcl
data_collection_rule = {
  transformations = {
    LAQueryLogs = "source | where QueryText !contains 'LAQueryLogs'"
  }
}
```

When overriding `transformations`, include every table that needs a transform. Tables without a transform still ingest normally.

Set `data_collection_rule = null` or `data_collection_rule = { enabled = false }` to skip DCR creation entirely.

## References

- [Transformations in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/data-collection/data-collection-transformations)
- [Workspace transformation DCR tutorial](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/tutorial-workspace-transformations-api)
- [UN-12652](https://unique-ch.atlassian.net/browse/UN-12652)


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.15 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.4 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.15 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_update_resource.workspace_dcr](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/update_resource) | resource |
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_log_analytics_workspace_table.basic_log_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace_table) | resource |
| [azurerm_monitor_data_collection_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) | resource |
| [azurerm_monitor_diagnostic_setting.dcr_log_errors](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_basic_log_tables"></a> [basic\_log\_tables](#input\_basic\_log\_tables) | Log Analytics workspace tables to configure with the Basic plan. | <pre>map(object({<br/>    retention_in_days = optional(number)<br/>  }))</pre> | <pre>{<br/>  "AKSControlPlane": {<br/>    "retention_in_days": 30<br/>  },<br/>  "ContainerLogV2": {<br/>    "retention_in_days": 30<br/>  }<br/>}</pre> | no |
| <a name="input_data_collection_rule"></a> [data\_collection\_rule](#input\_data\_collection\_rule) | Workspace-transform DCR configuration. By default, creates a DCR with kind<br/>WorkspaceTransforms and attaches it to the workspace via defaultDataCollectionRuleResourceId.<br/>Set to null or enabled = false to skip DCR creation and attachment. | <pre>object({<br/>    destination_name = optional(string)<br/>    enabled          = optional(bool, true)<br/>    name             = optional(string)<br/>    transformations  = optional(map(string))<br/>  })</pre> | `{}` | no |
| <a name="input_local_authentication_enabled"></a> [local\_authentication\_enabled](#input\_local\_authentication\_enabled) | Whether local authentication using workspace keys is enabled. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the workspace and optional DCR. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Log Analytics workspace. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name for the workspace and optional DCR. | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Workspace retention period in days. | `number` | `90` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | SKU of the Log Analytics workspace. | `string` | `"PerGB2018"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the workspace and optional DCR. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_flow_tables"></a> [data\_flow\_tables](#output\_data\_flow\_tables) | Log Analytics table names configured with ingestion-time transformations. |
| <a name="output_dcr_id"></a> [dcr\_id](#output\_dcr\_id) | Resource ID of the workspace-transform DCR, or null when data\_collection\_rule is disabled. |
| <a name="output_dcr_name"></a> [dcr\_name](#output\_dcr\_name) | Name of the workspace-transform DCR, or null when data\_collection\_rule is disabled. |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Resource ID of the Log Analytics workspace. |
| <a name="output_workspace_location"></a> [workspace\_location](#output\_workspace\_location) | Azure region of the Log Analytics workspace. |
| <a name="output_workspace_name"></a> [workspace\_name](#output\_workspace\_name) | Name of the Log Analytics workspace. |
| <a name="output_workspace_resource_group_name"></a> [workspace\_resource\_group\_name](#output\_workspace\_resource\_group\_name) | Resource group name of the Log Analytics workspace. |
<!-- END_TF_DOCS -->
