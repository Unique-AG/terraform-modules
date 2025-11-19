# Azure Activity Log Export

## Pre-requisites
- Reader access to the subscription
- Contributor access to configure diagnostic settings for the subscription
- An existing Event Hub and authorization rule for log export

## Features
- Export Azure Activity Logs to Event Hub
- Configurable log categories
- Supports all standard Activity Log categories (Administrative, Security, ServiceHealth, etc.)

## Important notes
- This module requires an existing Event Hub namespace and authorization rule
- The diagnostic setting is created at the subscription level
- Activity Logs are subscription-wide by design and cannot be filtered by resource (use Azure Resource Logs for resource-specific diagnostics)

## Module

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
| [azurerm_monitor_diagnostic_setting.activity_log_export](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_eventhub_namespace_authorization_rule.send](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/eventhub_namespace_authorization_rule) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_categories"></a> [categories](#input\_categories) | List of Activity Log categories to export. | `list(string)` | <pre>[<br/>  "Administrative",<br/>  "Security",<br/>  "ServiceHealth",<br/>  "Alert",<br/>  "Recommendation",<br/>  "Policy",<br/>  "Autoscale",<br/>  "ResourceHealth"<br/>]</pre> | no |
| <a name="input_eventhub"></a> [eventhub](#input\_eventhub) | Event Hub configuration for Activity Log export. | <pre>object({<br/>    name                    = string<br/>    resource_group_name     = string<br/>    namespace_name          = string<br/>    authorization_rule_name = string<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the diagnostic setting for Activity Log export. | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription ID whose Activity Log will be exported. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_setting"></a> [diagnostic\_setting](#output\_diagnostic\_setting) | Details of the Activity Log diagnostic setting. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the diagnostic setting. |
| <a name="output_name"></a> [name](#output\_name) | The name of the diagnostic setting. |
<!-- END_TF_DOCS -->
