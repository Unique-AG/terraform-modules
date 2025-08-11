# Azure Application Gateway

## Pre-requisites

- To deploy this module, you have at least the following permissions:
    + Reader of the subscription
    + Contributor of the resource group

## [Examples](./examples)

## Configuring the HTTP Listener with private IP

By default, the HTTP listener is configured using the public IP configuration. This can be switched to the private IP configuration by setting `private_frontend_enabled` to `true`. However, in this case the module will anyway create a frontend IP configuration for the public IP, since this is required by a standard Application Gateway v2 deployment. Having an Application Gateway provisioned with only private IP is only possible by [enabling a EnableApplicationGatewayNetworkIsolation preview feature](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-private-deployment)) and not currently supported by this module.

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
| [azurerm_web_application_firewall_policy.wafpolicy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscale_configuration"></a> [autoscale\_configuration](#input\_autoscale\_configuration) | Configuration for the autoscale configuration | <pre>object({<br/>    min_capacity = number<br/>    max_capacity = number<br/>  })</pre> | <pre>{<br/>  "max_capacity": 10,<br/>  "min_capacity": 1<br/>}</pre> | no |
| <a name="input_backend_address_pool"></a> [backend\_address\_pool](#input\_backend\_address\_pool) | Configuration for the backend\_address\_pool | <pre>object({<br/>    explicit_name = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_backend_http_settings"></a> [backend\_http\_settings](#input\_backend\_http\_settings) | Configuration for the backend\_http\_settings | <pre>object({<br/>    explicit_name         = optional(string)<br/>    cookie_based_affinity = optional(string, "Disabled")<br/>    port                  = optional(number, 80)<br/>    protocol              = optional(string, "Http")<br/>    request_timeout       = optional(number, 60)<br/>  })</pre> | `{}` | no |
| <a name="input_explicit_name"></a> [explicit\_name](#input\_explicit\_name) | Name for the Gateway if <name\_prefix>-appgw is not desired. | `string` | `null` | no |
| <a name="input_frontend_port"></a> [frontend\_port](#input\_frontend\_port) | Settings for the frontend port. | <pre>object({<br/>    explicit_name = optional(string)<br/>    port          = optional(number, 80)<br/>  })</pre> | `{}` | no |
| <a name="input_gateway_ip_configuration"></a> [gateway\_ip\_configuration](#input\_gateway\_ip\_configuration) | Defines which subnet the Application Gateway will be deployed in and under which name. | <pre>object({<br/>    explicit_name      = optional(string)<br/>    subnet_resource_id = string<br/>  })</pre> | n/a | yes |
| <a name="input_global_request_buffering_enabled"></a> [global\_request\_buffering\_enabled](#input\_global\_request\_buffering\_enabled) | Enable request buffering, setting it to false is incompatible with WAF\_v2 SKU. Refer to https://learn.microsoft.com/en-us/azure/application-gateway/proxy-buffers#request-buffer to understand the implications. | `bool` | `true` | no |
| <a name="input_global_response_buffering_enabled"></a> [global\_response\_buffering\_enabled](#input\_global\_response\_buffering\_enabled) | Enable response buffering, refer to https://learn.microsoft.com/en-us/azure/application-gateway/proxy-buffers#response-buffer to understand the implications. Defaults to false to support Unique AI server-sent events. | `bool` | `false` | no |
| <a name="input_http_listener"></a> [http\_listener](#input\_http\_listener) | Configuration for the http\_listener | <pre>object({<br/>    explicit_name = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_monitor_diagnostic_setting"></a> [monitor\_diagnostic\_setting](#input\_monitor\_diagnostic\_setting) | Configuration for the application gateway diagnostic setting | <pre>object({<br/>    name                       = optional(string)<br/>    log_analytics_workspace_id = string<br/>    enabled_log = optional(list(object({<br/>      category_group = string<br/>    })), [{ category_group = "allLogs" }])<br/>  })</pre> | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for naming resources | `string` | n/a | yes |
| <a name="input_private_frontend_ip_configuration"></a> [private\_frontend\_ip\_configuration](#input\_private\_frontend\_ip\_configuration) | Configuration for the frontend\_ip\_configuration that leverages a private IP address. | <pre>object({<br/>    explicit_name           = optional(string)<br/>    ip_address_resource_id  = string<br/>    address_allocation      = optional(string, "Static")<br/>    subnet_resource_id      = string<br/>    is_active_http_listener = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_public_frontend_ip_configuration"></a> [public\_frontend\_ip\_configuration](#input\_public\_frontend\_ip\_configuration) | Configuration for the frontend\_ip\_configuration that leverages a public IP address. Might become nullable once https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-private-deployment leaves Preview. | <pre>object({<br/>    explicit_name           = optional(string)<br/>    ip_address_resource_id  = string<br/>    ip_address              = optional(string)<br/>    is_active_http_listener = optional(bool, true)<br/>  })</pre> | n/a | yes |
| <a name="input_request_routing_rule"></a> [request\_routing\_rule](#input\_request\_routing\_rule) | Configuration for the request\_routing\_rule | <pre>object({<br/>    explicit_name = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The resource group to deploy the gateway to. | <pre>object({<br/>    name     = string<br/>    location = string<br/>  })</pre> | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the gateway | <pre>object({<br/>    name = string<br/>    tier = string<br/>  })</pre> | <pre>{<br/>  "name": "Standard_v2",<br/>  "tier": "Standard_v2"<br/>}</pre> | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | SSL policy configuration | <pre>object({<br/>    name = string<br/>    type = string<br/>  })</pre> | <pre>{<br/>  "name": "AppGwSslPolicy20220101",<br/>  "type": "Predefined"<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources. | `map(string)` | n/a | yes |
| <a name="input_waf_custom_rules_allow_hosts"></a> [waf\_custom\_rules\_allow\_hosts](#input\_waf\_custom\_rules\_allow\_hosts) | Allow monitoring agents to probe services. | <pre>object({<br/>    request_header_host = string<br/>    host_contains       = list(string)<br/>  })</pre> | <pre>{<br/>  "host_contains": [<br/>    "kubernetes.default.svc"<br/>  ],<br/>  "request_header_host": "host"<br/>}</pre> | no |
| <a name="input_waf_custom_rules_allow_https_challenges"></a> [waf\_custom\_rules\_allow\_https\_challenges](#input\_waf\_custom\_rules\_allow\_https\_challenges) | Allow HTTP-01 challenges e.g.from Let's Encrypt. | `bool` | `true` | no |
| <a name="input_waf_custom_rules_allow_monitoring_agents_to_probe_services"></a> [waf\_custom\_rules\_allow\_monitoring\_agents\_to\_probe\_services](#input\_waf\_custom\_rules\_allow\_monitoring\_agents\_to\_probe\_services) | Allow monitoring agents to probe services. | <pre>object({<br/>    request_header_user_agent = string<br/>    probe_path_equals         = list(string)<br/>  })</pre> | <pre>{<br/>  "probe_path_equals": [<br/>    "/probe",<br/>    "/chat/api/health",<br/>    "/knowledge-upload/api/health",<br/>    "/sidebar/browser",<br/>    "/debug/ready",<br/>    "/",<br/>    "/browser",<br/>    "/chat/probe",<br/>    "/ingestion/probe",<br/>    "/api/probe",<br/>    "/scope-management/probe",<br/>    "/health"<br/>  ],<br/>  "request_header_user_agent": "Better Stack Better Uptime Bot Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"<br/>}</pre> | no |
| <a name="input_waf_custom_rules_exempted_request_path_begin_withs"></a> [waf\_custom\_rules\_exempted\_request\_path\_begin\_withs](#input\_waf\_custom\_rules\_exempted\_request\_path\_begin\_withs) | The request URIs that are exempted from further checks. This is a workaround to allowlist certain URLs to bypass further blocking checks (in this case the body size). | `list(string)` | <pre>[<br/>  "/scoped/ingestion/upload",<br/>  "/ingestion/v1/content"<br/>]</pre> | no |
| <a name="input_waf_custom_rules_ip_allow_list"></a> [waf\_custom\_rules\_ip\_allow\_list](#input\_waf\_custom\_rules\_ip\_allow\_list) | List of IP addresses or ranges which are allowed to pass the WAF. An empty list means all IPs are allowed. | `list(string)` | `[]` | no |
| <a name="input_waf_custom_rules_unique_access_to_paths_ip_restricted"></a> [waf\_custom\_rules\_unique\_access\_to\_paths\_ip\_restricted](#input\_waf\_custom\_rules\_unique\_access\_to\_paths\_ip\_restricted) | Only allow certain IP matches to access selected paths. Passing no IP means all requests get blocked for these paths. | <pre>map(object({<br/>    ip_allow_list    = list(string)<br/>    path_begin_withs = list(string)<br/>  }))</pre> | <pre>{<br/>  "chat-export": {<br/>    "ip_allow_list": [],<br/>    "path_begin_withs": [<br/>      "/chat/analytics/user-chat-export"<br/>    ]<br/>  }<br/>}</pre> | no |
| <a name="input_waf_managed_rules"></a> [waf\_managed\_rules](#input\_waf\_managed\_rules) | Default configuration for managed rules. | <pre>object({<br/>    owasp_rules = optional(list(<br/>      object({<br/>        rule_group_name = string<br/>        rules = list(<br/>          object({<br/>            id      = string<br/>            action  = optional(string, "AnomalyScoring")<br/>            enabled = optional(bool, false)<br/>          })<br/>        )<br/>      })<br/>    ))<br/>    bot_rules = optional(list(<br/>      object({<br/>        rule_group_name = string<br/>        rules = list(<br/>          object({<br/>            id      = string<br/>            action  = optional(string, "AnomalyScoring")<br/>            enabled = optional(bool, false)<br/>          })<br/>        )<br/>      })<br/>    ))<br/>    exclusions = optional(list(<br/>      object({<br/>        match_variable          = string<br/>        selector_match_operator = string<br/>        selector                = string<br/>        excluded_rule_set = optional(object({<br/>          type            = string<br/>          version         = string<br/>          excluded_rules  = optional(list(string), null)<br/>          rule_group_name = string<br/>        }), null)<br/>      })<br/>    ))<br/>  })</pre> | <pre>{<br/>  "bot_rules": [<br/>    {<br/>      "rule_group_name": "UnknownBots",<br/>      "rules": [<br/>        {<br/>          "action": "Log",<br/>          "enabled": false,<br/>          "id": "300300"<br/>        },<br/>        {<br/>          "action": "Log",<br/>          "enabled": false,<br/>          "id": "300700"<br/>        }<br/>      ]<br/>    }<br/>  ],<br/>  "exclusions": [<br/>    {<br/>      "excluded_rule_set": {<br/>        "excluded_rules": [<br/>          "941130",<br/>          "941170"<br/>        ],<br/>        "rule_group_name": "REQUEST-941-APPLICATION-ATTACK-XSS",<br/>        "type": "OWASP",<br/>        "version": "3.2"<br/>      },<br/>      "match_variable": "RequestArgNames",<br/>      "selector": "variables.input.favicon,variables.input.logoHeader,variables.input.logoNavbar",<br/>      "selector_match_operator": "EqualsAny"<br/>    },<br/>    {<br/>      "excluded_rule_set": {<br/>        "rule_group_name": "REQUEST-941-APPLICATION-ATTACK-XSS",<br/>        "type": "OWASP",<br/>        "version": "3.2"<br/>      },<br/>      "match_variable": "RequestArgNames",<br/>      "selector": "variables.input.text,variables.text",<br/>      "selector_match_operator": "EqualsAny"<br/>    },<br/>    {<br/>      "excluded_rule_set": {<br/>        "rule_group_name": "REQUEST-942-APPLICATION-ATTACK-SQLI",<br/>        "type": "OWASP",<br/>        "version": "3.2"<br/>      },<br/>      "match_variable": "RequestArgNames",<br/>      "selector": "variables.input.text,variables.text,variables.input.modules.upsert.create.configuration.systemPromptSearch",<br/>      "selector_match_operator": "EqualsAny"<br/>    },<br/>    {<br/>      "excluded_rule_set": {<br/>        "rule_group_name": "REQUEST-932-APPLICATION-ATTACK-RCE",<br/>        "type": "OWASP",<br/>        "version": "3.2"<br/>      },<br/>      "match_variable": "RequestArgNames",<br/>      "selector": "variables.input.text,variables.text,variables.input.modules.upsert.create.configuration.systemPromptSearch",<br/>      "selector_match_operator": "EqualsAny"<br/>    },<br/>    {<br/>      "excluded_rule_set": {<br/>        "rule_group_name": "REQUEST-933-APPLICATION-ATTACK-PHP",<br/>        "type": "OWASP",<br/>        "version": "3.2"<br/>      },<br/>      "match_variable": "RequestArgNames",<br/>      "selector": "variables.input.text,variables.text,variables.input.modules.upsert.create.configuration.systemPromptSearch",<br/>      "selector_match_operator": "EqualsAny"<br/>    },<br/>    {<br/>      "excluded_rule_set": {<br/>        "rule_group_name": "REQUEST-942-APPLICATION-ATTACK-SQLI",<br/>        "type": "OWASP",<br/>        "version": "3.2"<br/>      },<br/>      "match_variable": "RequestCookieNames",<br/>      "selector": "__Secure-next-auth.session-token",<br/>      "selector_match_operator": "EqualsAny"<br/>    }<br/>  ],<br/>  "owasp_rules": [<br/>    {<br/>      "rule_group_name": "REQUEST-913-SCANNER-DETECTION",<br/>      "rules": [<br/>        {<br/>          "id": "913101"<br/>        }<br/>      ]<br/>    },<br/>    {<br/>      "rule_group_name": "REQUEST-920-PROTOCOL-ENFORCEMENT",<br/>      "rules": [<br/>        {<br/>          "id": "920230"<br/>        },<br/>        {<br/>          "id": "920300"<br/>        },<br/>        {<br/>          "id": "920320"<br/>        },<br/>        {<br/>          "id": "920420"<br/>        }<br/>      ]<br/>    },<br/>    {<br/>      "rule_group_name": "REQUEST-931-APPLICATION-ATTACK-RFI",<br/>      "rules": [<br/>        {<br/>          "id": "931130"<br/>        }<br/>      ]<br/>    },<br/>    {<br/>      "rule_group_name": "REQUEST-932-APPLICATION-ATTACK-RCE",<br/>      "rules": [<br/>        {<br/>          "id": "932100"<br/>        },<br/>        {<br/>          "id": "932105"<br/>        },<br/>        {<br/>          "id": "932115"<br/>        },<br/>        {<br/>          "id": "932130"<br/>        }<br/>      ]<br/>    },<br/>    {<br/>      "rule_group_name": "REQUEST-933-APPLICATION-ATTACK-PHP",<br/>      "rules": [<br/>        {<br/>          "id": "933160"<br/>        }<br/>      ]<br/>    },<br/>    {<br/>      "rule_group_name": "REQUEST-942-APPLICATION-ATTACK-SQLI",<br/>      "rules": [<br/>        {<br/>          "id": "942100"<br/>        },<br/>        {<br/>          "id": "942110"<br/>        },<br/>        {<br/>          "id": "942130"<br/>        },<br/>        {<br/>          "id": "942150"<br/>        },<br/>        {<br/>          "id": "942190"<br/>        },<br/>        {<br/>          "id": "942200"<br/>        },<br/>        {<br/>          "id": "942260"<br/>        },<br/>        {<br/>          "id": "942330"<br/>        },<br/>        {<br/>          "id": "942340"<br/>        },<br/>        {<br/>          "id": "942370"<br/>        },<br/>        {<br/>          "id": "942380"<br/>        },<br/>        {<br/>          "id": "942410"<br/>        },<br/>        {<br/>          "id": "942430"<br/>        },<br/>        {<br/>          "id": "942440"<br/>        },<br/>        {<br/>          "id": "942450"<br/>        }<br/>      ]<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_waf_policy_settings"></a> [waf\_policy\_settings](#input\_waf\_policy\_settings) | The mode of the firewall policy (Prevention or Detection) | <pre>object({<br/>    explicit_name               = optional(string)<br/>    mode                        = optional(string, "Prevention")<br/>    request_body_check          = optional(bool, true)<br/>    file_upload_limit_in_mb     = optional(number, 512)<br/>    max_request_body_size_in_kb = optional(number, 2000)<br/>    request_body_enforcement    = optional(bool, true)<br/>  })</pre> | <pre>{<br/>  "file_upload_limit_in_mb": 512,<br/>  "max_request_body_size_in_kb": 2000,<br/>  "mode": "Prevention",<br/>  "request_body_check": true,<br/>  "request_body_enforcement": true<br/>}</pre> | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Specifies a list of Availability Zones in which this Application Gateway should be located. Changing this forces a new Application Gateway to be created. | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appgw_id"></a> [appgw\_id](#output\_appgw\_id) | The ID of the Application Gateway |
| <a name="output_appgw_name"></a> [appgw\_name](#output\_appgw\_name) | The name of the Application Gateway |
<!-- END_TF_DOCS -->

## Upgrade Guide

### ~> `4.0.0`

> [!CAUTION]
> `4.0.0` currently is a release candidate. Refrain from upgrading for production clusters. When upgrading non-production environments inspect the diffs carefully and report issues where changes occur un-intended or sub-ideal.

This version introduces comprehensive WAF (Web Application Firewall) support. Additionally, true to the [Design principles](https://github.com/Unique-AG/terraform-modules/blob/d8dd200b7871f55b8a274903a9865161b7f1ec61/DESIGN.md) the module no longer implicitly or forcibly creates a public IP address; control over networking and the IP addresses is passed to the user/caller. While doing so the variable syntax was overworked extensively to future-proof the module and allow for more customization. Follow this guide to upgrade to `~> 4.0.0`.

#### Variable mapping
Nearly all variables where reworked to have consistent names and address their effective _target_. Refer to this map, the [README](https://github.com/Unique-AG/terraform-modules/blob/d8dd200b7871f55b8a274903a9865161b7f1ec61/README.md) and the example below to find a correct migration path.

> [!NOTE]
> Few variables are actually required. When migrating, only previously used variables would be requried, the rest can be omitted as before.

|Old variable name|New variable
|---|---|
|`agw_diagnostic_name`|`monitor_diagnostic_setting.name`|
|`application_gateway_name`|`explicit_name`|
|`backend_address_pool_name`|`backend_address_pool.explicit_name`|
|`backend_http_settings_name`|`backend_http_settings.name`|
|`file_upload_limit_in_mb`|`waf_policy_settings.file_upload_limit_in_mb`|
|`frontend_ip_config_name`|`public_frontend_ip_configuration.explicit_name`|
|`frontend_ip_private_config_name`|`private_frontend_ip_configuration.explicit_name`|
|`frontend_port_name`|`frontend_port.explicit_name`|
|`gateway_mode`|`waf_policy_settings.mode`|
|`gateway_sku`|`sku.name`|
|`gateway_tier`|`sku.tier`|
|`gw_ip_config_name`|`gateway_ip_configuration.name`|
|`http_listener_name`|`http_listener.explicit_name`|
|`ip_name`|⚠️ _removed_|
|`log_analytics_workspace_id`|`monitor_diagnostic_setting.log_analytics_workspace_id`|
|`max_capacity`|`autoscale_configuration.max_capacity`|
|`max_request_body_size_exempted_request_uris`|`waf_custom_rules_exempted_request_path_begin_withs`|
|`max_request_body_size_in_kb`|`waf_policy_settings.max_request_body_size_in_kb`|
|`min_capacity`|`autoscale_configuration.min_capacity`|
|`name_prefix`|_unchanged_|
|`private_frontend_enabled`|_replaced by mutually exclusive objects `public_frontend_ip_configuration` / `private_frontend_ip_configuration`_|
|`private_ip`|`private_frontend_ip_configuration.ip_address_resource_id`|
|`public_ip_address_id`|`public_frontend_ip_configuration.ip_address_resource_id`|
|`request_buffering_enabled`|`global_request_buffering_enabled`|
|`resource_group_location`|`resource_group.location`|
|`resource_group_name`|`resource_group.name`|
|`response_buffering_enabled`|`global_response_buffering_enabled`|
|`routing_rule_name`|`request_routing_rule.explicit_name`|
|`ssl_policy_name`|`ssl_policy.name`|
|`ssl_policy_type`|`ssl_policy.type`|
|`subnet_appgw`|`gateway_ip_configuration.subnet_resource_id`|
|`tags`|_unchanged_|
|`waf_ip_allow_list`|`waf_custom_rules_ip_allow_list`|
|`waf_policy_managed_rule_settings`|`waf_managed_rules`|
|`waf_policy_name`|`waf_policy_settings.explicit_name`|
|`zones`|_unchanged_|

#### (Public) IP Address creation and maintenance
The IP address configuration moves into its own blocks and becomes mandatory. Refer to the examples folder to see the module-external IP address creation.

Unique is aware that this change causes downtime due to potentialy DNS changes and propagation times. The change was deemed necessary as the old module was released rather pre-maturely from internal usage without adhering truely to the [Design principles](https://github.com/Unique-AG/terraform-modules/blob/d8dd200b7871f55b8a274903a9865161b7f1ec61/DESIGN.md).

#### WAF Policies
Adhering to _secure by default_ the module now defaults to using a set of managed and custom rules for the Web Application Firewall Policy when using the `WAF_v2` SKU. These settings are in their base version compatible with Unique AI but can be further tweaked or hardened by the callers demands.

Refer to the `waf_*` variable descriptions to see which customizations and settings are available.

This module did not offer these settings in previous versions so there is no variable map available. Callers please test and verify the changes on a test environment or get in touch with Unique Forward-Facing Engineering Teams.

#### Opinionated migration example
The following migration shows an example migration from ~> `3.3` to `4.0`.

```diff
diff --git a/path/agw.tf b/path/agw.tf
index 2e43158285..f1e4606ad5 100644
--- a/path/agw.tf
+++ b/path/agw.tf
@@ -25,24 +25,39 @@ data "azurerm_subnet" "agw" {
 }

 module "agw" {
-  source                   = "github.com/unique-ag/terraform-modules.git//modules/azure-application-gateway?depth=1&ref=azure-application-gateway-3.3.0"
-  application_gateway_name = "agw-${var.tenant_name}-${var.tenant_environment}"
-  gateway_mode             = var.agw_gateway_mode
-  gateway_sku              = "WAF_v2"
-  gateway_tier             = "WAF_v2"
-  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
-  name_prefix             = "agw"
-  public_ip_address_id    = data.azurerm_public_ip.public_ip_address_ingress.id
-  private_ip              = cidrhost(data.azurerm_subnet.agw.address_prefix, 6)
-  resource_group_location = data.azurerm_resource_group.core.location
-  resource_group_name     = data.azurerm_resource_group.core.name
-  subnet_appgw            = data.azurerm_subnet.agw.id
-  tags                    = local.tags
-
-  waf_ip_allow_list = concat(
-    compact(var.ip_list_client),
-    compact(values(var.ip_list_unique)),
-    compact(flatten(values(var.ip_list_3rd_party))),
-    [data.azurerm_public_ip.public_ip_address_egress.ip_address]
-  )
+  source = "github.com/unique-ag/terraform-modules.git//modules/azure-application-gateway?depth=1&ref=azure-application-gateway-4.0.0"
+
+  explicit_name = "agw-${var.tenant_name}-${var.tenant_environment}"
+  name_prefix   = "agw"
+  tags          = local.tags
+
+  gateway_ip_configuration = {
+    subnet_resource_id = data.azurerm_subnet.agw.id
+  }
+
+  monitor_diagnostic_setting = {
+    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
+  }
+
+  public_frontend_ip_configuration = {
+    ip_address_resource_id = data.azurerm_public_ip.public_ip_address_ingress.id
+    ip_address             = cidrhost(data.azurerm_subnet.agw.address_prefix, 6)
+  }
+
+  resource_group = {
+    name     = data.azurerm_resource_group.core.name
+    location = data.azurerm_resource_group.core.location
+  }
+
+  sku = {
+    name = "WAF_v2"
+    tier = "WAF_v2"
+  }
+
+  waf_policy_settings = {
+    mode = "Detection"
+  }
+
+  waf_custom_rules_ip_allow_list = concat(compact(var.ip_list_client), compact(values(var.ip_list_unique)), compact(flatten(values(var.ip_list_3rd_party))), [data.azurerm_public_ip.public_ip_address_egress.ip_address])
 }
```

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