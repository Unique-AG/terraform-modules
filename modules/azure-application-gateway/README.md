# Azure Application Gateway

## Pre-requisites

- To deploy this module, you have at least the following permissions:
    + Reader of the subscription
    + Contributor of the resource group

## [Examples](./examples)

## Configuring the HTTP Listener with private IP

By default, the HTTP listener is configured using the public IP configuration. This can be switched to the private IP configuration by setting `private_frontend_enabled` to `true`. However, in this case the module will anyway create a frontend IP configuration for the public IP, since this is required by a standard Application Gateway v2 deployment. Having an Application Gateway provisioned with only private IP is only possible by [enabling a EnableApplicationGatewayNetworkIsolation preview feature](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-private-deployment)) and not currently supported by this module.

## Private CA Certificate Support

This module supports uploading private Certificate Authority (CA) root certificates to enable the Application Gateway to trust backend services that use certificates issued by a private CA. This is particularly useful in enterprise environments where internal services use certificates from corporate CAs.

### Configuration

To configure private CA support, use the `trusted_root_certificates` variable to upload your CA certificates:

```hcl
module "application_gateway" {
  source = "path/to/module"

  # ... other configuration ...

  # Upload private CA root certificates
  trusted_root_certificates = [
    {
      name             = "corporate-ca-root"
      certificate_path = "./certificates/corporate-ca-root.cer"
    },
    {
      name             = "partner-ca-root"
      certificate_path = "./certificates/partner-ca-root.cer"
    }
  ]

  # Configure backend HTTP settings to trust the uploaded CAs
  backend_http_settings_trusted_root_certificate_names  = ["corporate-ca-root", "partner-ca-root"]
}
```

### Certificate Requirements

- Certificates must be in `.cer`, `.crt`, or `.pem` format
- The certificate should contain the root CA certificate (not intermediate certificates)
- Ensure the certificate file is accessible to Terraform during execution

**Note**: The module defaults to HTTP on port 80. When using private CA certificates with HTTPS backends, configure `backend_http_settings_protocol = "Https"` and `backend_http_settings_port = 443`.

### Example

See the [private-ca example](./examples/private-ca/) for a complete working configuration.

# Module

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
| [azurerm_application_gateway.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_monitor_diagnostic_setting.agw_diagnostic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_public_ip.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_web_application_firewall_policy.wafpolicy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agw_diagnostic_name"></a> [agw\_diagnostic\_name](#input\_agw\_diagnostic\_name) | Name for the agw\_diagnostic | `string` | `null` | no |
| <a name="input_application_gateway_name"></a> [application\_gateway\_name](#input\_application\_gateway\_name) | Name for the Gateway | `string` | `null` | no |
| <a name="input_backend_address_pool_name"></a> [backend\_address\_pool\_name](#input\_backend\_address\_pool\_name) | Name for the backend\_address\_pool | `string` | `null` | no |
| <a name="input_backend_http_settings_name"></a> [backend\_http\_settings\_name](#input\_backend\_http\_settings\_name) | Name for the backend\_http\_settings | `string` | `null` | no |
| <a name="input_backend_http_settings_port"></a> [backend\_http\_settings\_port](#input\_backend\_http\_settings\_port) | Port for backend HTTP settings | `number` | `80` | no |
| <a name="input_backend_http_settings_protocol"></a> [backend\_http\_settings\_protocol](#input\_backend\_http\_settings\_protocol) | Protocol for backend HTTP settings | `string` | `"Http"` | no |
| <a name="input_backend_http_settings_trusted_root_certificate_names"></a> [backend\_http\_settings\_trusted\_root\_certificate\_names](#input\_backend\_http\_settings\_trusted\_root\_certificate\_names) | Names of trusted root certificates to associate with backend HTTP settings | `list(string)` | `[]` | no |
| <a name="input_file_upload_limit_in_mb"></a> [file\_upload\_limit\_in\_mb](#input\_file\_upload\_limit\_in\_mb) | The file upload limit in MB. This is the maximum size of the file that can be uploaded through the application gateway. Revert it to 100 if you want to adhere to the policies defaults. | `number` | `512` | no |
| <a name="input_frontend_ip_config_name"></a> [frontend\_ip\_config\_name](#input\_frontend\_ip\_config\_name) | Name for the frontend\_ip\_config | `string` | `null` | no |
| <a name="input_frontend_ip_private_config_name"></a> [frontend\_ip\_private\_config\_name](#input\_frontend\_ip\_private\_config\_name) | Name for the frontend\_ip\_private\_config | `string` | `null` | no |
| <a name="input_frontend_port_name"></a> [frontend\_port\_name](#input\_frontend\_port\_name) | Name for the frontend\_port | `string` | `null` | no |
| <a name="input_gateway_mode"></a> [gateway\_mode](#input\_gateway\_mode) | The mode of the gateway (Prevention or Detection) | `string` | `"Prevention"` | no |
| <a name="input_gateway_sku"></a> [gateway\_sku](#input\_gateway\_sku) | The SKU of the gateway | `string` | `"Standard_v2"` | no |
| <a name="input_gateway_tier"></a> [gateway\_tier](#input\_gateway\_tier) | The tier of the gateway | `string` | `"Standard_v2"` | no |
| <a name="input_gw_ip_config_name"></a> [gw\_ip\_config\_name](#input\_gw\_ip\_config\_name) | Name for the gw\_ip\_config | `string` | `null` | no |
| <a name="input_http_listener_name"></a> [http\_listener\_name](#input\_http\_listener\_name) | Name for the http\_listener | `string` | `null` | no |
| <a name="input_ip_name"></a> [ip\_name](#input\_ip\_name) | The name of the public IP address. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The ID of the Log Analytics Workspace | `string` | `null` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | Maximum capacity for autoscaling | `number` | `2` | no |
| <a name="input_max_request_body_size_exempted_request_uris"></a> [max\_request\_body\_size\_exempted\_request\_uris](#input\_max\_request\_body\_size\_exempted\_request\_uris) | The request URIs that are exempted from the max request body size. This is a list of request URIs that are exempted from the max request body size. If the WAF is running in Prevention mode, these URIs will be exempted from the max request body size. This setting has no effect if the WAF is running in Detection mode or the gateway isn't using the WAF\_v2 SKU. | `list(string)` | <pre>[<br/>  "/scoped/ingestion/upload",<br/>  "/ingestion/v1/content"<br/>]</pre> | no |
| <a name="input_max_request_body_size_in_kb"></a> [max\_request\_body\_size\_in\_kb](#input\_max\_request\_body\_size\_in\_kb) | The max request body size in KB. This defaults to the maximum to support as many use cases as possible. Lower it back to its default of 128 if you want to adhere to the policies defaults. | `number` | `2000` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | Minimum capacity for autoscaling | `number` | `1` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for naming resources | `string` | n/a | yes |
| <a name="input_private_frontend_enabled"></a> [private\_frontend\_enabled](#input\_private\_frontend\_enabled) | Enable the private frontend IP configuration for the http listener. If disabled, uses public frontend IP configuration | `bool` | `false` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP address for the frontend IP configuration | `string` | n/a | yes |
| <a name="input_public_ip_address_id"></a> [public\_ip\_address\_id](#input\_public\_ip\_address\_id) | The ID of the public IP address | `string` | `""` | no |
| <a name="input_request_buffering_enabled"></a> [request\_buffering\_enabled](#input\_request\_buffering\_enabled) | Enable request buffering | `bool` | `true` | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | The location of the resource group. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_response_buffering_enabled"></a> [response\_buffering\_enabled](#input\_response\_buffering\_enabled) | Enable response buffering | `bool` | `false` | no |
| <a name="input_routing_rule_name"></a> [routing\_rule\_name](#input\_routing\_rule\_name) | Name for the routing\_rule | `string` | `null` | no |
| <a name="input_ssl_policy_name"></a> [ssl\_policy\_name](#input\_ssl\_policy\_name) | Name of the SSL policy | `string` | `"AppGwSslPolicy20220101"` | no |
| <a name="input_ssl_policy_type"></a> [ssl\_policy\_type](#input\_ssl\_policy\_type) | Type of the SSL policy | `string` | `"Predefined"` | no |
| <a name="input_subnet_appgw"></a> [subnet\_appgw](#input\_subnet\_appgw) | The ID of the subnet for the application gateway | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources. | `map(string)` | n/a | yes |
| <a name="input_trusted_root_certificates"></a> [trusted\_root\_certificates](#input\_trusted\_root\_certificates) | Configuration for trusted root certificates (e.g., for private CAs). Each certificate will be uploaded to the Application Gateway and can be referenced in backend HTTP settings. | <pre>list(object({<br/>    name             = string<br/>    certificate_path = string<br/>  }))</pre> | `[]` | no |
| <a name="input_waf_ip_allow_list"></a> [waf\_ip\_allow\_list](#input\_waf\_ip\_allow\_list) | List of IP addresses or ranges which are allowed to pass the WAF. | `list(string)` | `[]` | no |
| <a name="input_waf_policy_managed_rule_settings"></a> [waf\_policy\_managed\_rule\_settings](#input\_waf\_policy\_managed\_rule\_settings) | n/a | <pre>list(<br/>    object(<br/>      {<br/>        rule_group_name   = string<br/>        disabled_rule_ids = list(string)<br/>      }<br/>    )<br/>  )</pre> | <pre>[<br/>  {<br/>    "disabled_rule_ids": [<br/>      "200002",<br/>      "200003",<br/>      "200004"<br/>    ],<br/>    "rule_group_name": "General"<br/>  },<br/>  {<br/>    "disabled_rule_ids": [<br/>      "911100"<br/>    ],<br/>    "rule_group_name": "REQUEST-911-METHOD-ENFORCEMENT"<br/>  },<br/>  {<br/>    "disabled_rule_ids": [<br/>      "913100",<br/>      "913101",<br/>      "913102",<br/>      "913110",<br/>      "913120"<br/>    ],<br/>    "rule_group_name": "REQUEST-913-SCANNER-DETECTION"<br/>  },<br/>  {<br/>    "disabled_rule_ids": [<br/>      "920100",<br/>      "920120",<br/>      "920121",<br/>      "920160",<br/>      "920170",<br/>      "920171",<br/>      "920180",<br/>      "920190",<br/>      "920200",<br/>      "920201",<br/>      "920202",<br/>      "920210",<br/>      "920220",<br/>      "920230",<br/>      "920240",<br/>      "920250",<br/>      "920260",<br/>      "920270",<br/>      "920271",<br/>      "920272",<br/>      "920273",<br/>      "920274",<br/>      "920280",<br/>      "920290",<br/>      "920300",<br/>      "920310",<br/>      "920311",<br/>      "920320",<br/>      "920330",<br/>      "920340",<br/>      "920341",<br/>      "920350",<br/>      "920420",<br/>      "920430",<br/>      "920440",<br/>      "920450",<br/>      "920460",<br/>      "920470",<br/>      "920480"<br/>    ],<br/>    "rule_group_name": "REQUEST-920-PROTOCOL-ENFORCEMENT"<br/>  },<br/>  {<br/>    "disabled_rule_ids": [<br/>      "921110",<br/>      "921120",<br/>      "921130",<br/>      "921140",<br/>      "921150",<br/>      "921151",<br/>      "921160",<br/>      "921170",<br/>      "921180"<br/>    ],<br/>    "rule_group_name": "REQUEST-921-PROTOCOL-ATTACK"<br/>  },<br/>  {<br/>    "disabled_rule_ids": [<br/>      "930100",<br/>      "930110",<br/>      "930120",<br/>      "930130"<br/>    ],<br/>    "rule_group_name": "REQUEST-930-APPLICATION-ATTACK-LFI"<br/>  },<br/>  {<br/>    "disabled_rule_ids": [<br/>      "931100",<br/>      "931110",<br/>      "931120",<br/>      "931130"<br/>    ],<br/>    "rule_group_name": "REQUEST-931-APPLICATION-ATTACK-RFI"<br/>  },<br/>  {<br/>    "disabled_rule_ids": [<br/>      "932100",<br/>      "932105",<br/>      "932106",<br/>      "932110",<br/>      "932115",<br/>      "932120",<br/>      "932130",<br/>      "932140",<br/>      "932150",<br/>      "932160",<br/>      "932170",<br/>      "932171",<br/>      "932180",<br/>      "932190"<br/>    ],<br/>    "rule_group_name": "REQUEST-932-APPLICATION-ATTACK-RCE"<br/>  },<br/>  {<br/>    "disabled_rule_ids": [<br/>      "933100",<br/>      "933110",<br/>      "933111",<br/>      "933120",<br/>      "933130",<br/>      "933131",<br/>      "933140",<br/>      "933150",<br/>      "933151",<br/>      "933160",<br/>      "933161",<br/>      "933170",<br/>      "933180",<br/>      "933190",<br/>      "933200",<br/>      "933210"<br/>    ],<br/>    "rule_group_name": "REQUEST-933-APPLICATION-ATTACK-PHP"<br/>  },<br/>  {<br/>    "disabled_rule_ids": [<br/>      "941100",<br/>      "941101",<br/>      "941110",<br/>      "941120",<br/>      "941130",<br/>      "941140",<br/>      "941150",<br/>      "941160",<br/>      "941170",<br/>      "941180",<br/>      "941190",<br/>      "941200",<br/>      "941210",<br/>      "941220",<br/>      "941230",<br/>      "941240",<br/>      "941250",<br/>      "941260",<br/>      "941270",<br/>      "941280",<br/>      "941290",<br/>      "941300",<br/>      "941310",<br/>      "941320",<br/>      "941330",<br/>      "941340",<br/>      "941350",<br/>      "941360"<br/>    ],<br/>    "rule_group_name": "REQUEST-941-APPLICATION-ATTACK-XSS"<br/>  },<br/>  {<br/>    "disabled_rule_ids": [<br/>      "942100",<br/>      "942110",<br/>      "942120",<br/>      "942130",<br/>      "942140",<br/>      "942150",<br/>      "942160",<br/>      "942170",<br/>      "942180",<br/>      "942190",<br/>      "942200",<br/>      "942210",<br/>      "942220",<br/>      "942230",<br/>      "942240",<br/>      "942250",<br/>      "942251",<br/>      "942260",<br/>      "942270",<br/>      "942280",<br/>      "942290",<br/>      "942300",<br/>      "942310",<br/>      "942320",<br/>      "942330",<br/>      "942340",<br/>      "942350",<br/>      "942360",<br/>      "942361",<br/>      "942370",<br/>      "942380",<br/>      "942390",<br/>      "942400",<br/>      "942410",<br/>      "942420",<br/>      "942421",<br/>      "942430",<br/>      "942431",<br/>      "942432",<br/>      "942440",<br/>      "942450",<br/>      "942460",<br/>      "942470",<br/>      "942480",<br/>      "942490",<br/>      "942500"<br/>    ],<br/>    "rule_group_name": "REQUEST-942-APPLICATION-ATTACK-SQLI"<br/>  },<br/>  {<br/>    "disabled_rule_ids": [<br/>      "943100",<br/>      "943110",<br/>      "943120"<br/>    ],<br/>    "rule_group_name": "REQUEST-943-APPLICATION-ATTACK-SESSION-FIXATION"<br/>  },<br/>  {<br/>    "disabled_rule_ids": [<br/>      "944100",<br/>      "944110",<br/>      "944120",<br/>      "944130",<br/>      "944200",<br/>      "944210",<br/>      "944240",<br/>      "944250"<br/>    ],<br/>    "rule_group_name": "REQUEST-944-APPLICATION-ATTACK-JAVA"<br/>  },<br/>  {<br/>    "disabled_rule_ids": [<br/>      "800100",<br/>      "800110",<br/>      "800111",<br/>      "800112",<br/>      "800113"<br/>    ],<br/>    "rule_group_name": "Known-CVEs"<br/>  }<br/>]</pre> | no |
| <a name="input_waf_policy_name"></a> [waf\_policy\_name](#input\_waf\_policy\_name) | Name of the WAF policy | `string` | `"default-waf-policy-name"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Specifies a list of Availability Zones in which this Application Gateway should be located. Changing this forces a new Application Gateway to be created. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appgw_id"></a> [appgw\_id](#output\_appgw\_id) | The ID of the Application Gateway |
| <a name="output_appgw_ip_address"></a> [appgw\_ip\_address](#output\_appgw\_ip\_address) | The public IP address of the Application Gateway |
| <a name="output_appgw_name"></a> [appgw\_name](#output\_appgw\_name) | The name of the Application Gateway |
<!-- END_TF_DOCS -->

## Remarks

### `3.3.1`
This version addresses a permanent drift in the AzureRM provider where Microsoft seems to have [silently made all Gateways Zone redudant (changed the API behaviour)](https://github.com/hashicorp/terraform-provider-azurerm/issues/30129).

The permanent drift can be fixed by going to this version and setting `zones` to the drift.

```tf
module "agw" {
    …
    zones = ["1", "2", "3"]
}
```

While the upstream fix is not ideal, this solves the permanent recreation of the resource until the underlying issue is addressed.
