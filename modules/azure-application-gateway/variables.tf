variable "autoscale_configuration" {
  description = "Configuration for the autoscale configuration"
  type = object({
    min_capacity = optional(number, 1)
    max_capacity = optional(number, 10)
  })
  default = {
    min_capacity = 1
    max_capacity = 10
  }

  validation {
    condition     = var.autoscale_configuration.min_capacity >= 0
    error_message = "The min_capacity must be at least 0."
  }

  validation {
    condition     = var.autoscale_configuration.max_capacity <= 125
    error_message = "The max_capacity must be at most 125."
  }

  validation {
    condition     = var.autoscale_configuration.max_capacity > var.autoscale_configuration.min_capacity
    error_message = "The max_capacity must be greater than min_capacity."
  }
}

variable "explicit_name" {
  description = "Name for the Gateway if <name_prefix>-appgw is not desired."
  type        = string
  default     = null
}

variable "frontend_port" {
  description = "Settings for the frontend port."
  type = object({
    explicit_name = optional(string)
    port          = optional(number, 80)
  })
  default = {}

  validation {
    condition     = var.frontend_port.port >= 1 && var.frontend_port.port <= 65535
    error_message = "The port must be between 1 and 65535."
  }
}

variable "gateway_ip_configuration" {
  description = "Defines which subnet the Application Gateway will be deployed in and under which name."
  type = object({
    explicit_name      = optional(string)
    subnet_resource_id = string
  })

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/virtualNetworks/.+/subnets/.+$", var.gateway_ip_configuration.subnet_resource_id))
    error_message = "The subnet_resource_id must be a valid Azure subnet resource ID."
  }
}

variable "global_request_buffering_enabled" {
  description = "Enable request buffering, setting it to false is incompatible with WAF_v2 SKU. Refer to https://learn.microsoft.com/en-us/azure/application-gateway/proxy-buffers#request-buffer to understand the implications."
  type        = bool
  default     = true

  validation {
    condition     = var.global_request_buffering_enabled == true || var.sku.tier != "WAF_v2"
    error_message = "Request buffering cannot be disabled when using WAF_v2 SKU."
  }
}

variable "global_response_buffering_enabled" {
  description = "Enable response buffering, refer to https://learn.microsoft.com/en-us/azure/application-gateway/proxy-buffers#response-buffer to understand the implications. Defaults to false to support Unique AI server-sent events."
  type        = bool
  default     = false
}

variable "monitor_diagnostic_setting" {
  description = "Configuration for the application gateway diagnostic setting"
  type = object({
    explicit_name              = optional(string)
    log_analytics_workspace_id = string
    enabled_log = optional(list(object({
      category_group = string
    })), [{ category_group = "allLogs" }])
  })
  default = null
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  validation {
    condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 20
    error_message = "The name_prefix must be between 1 and 20 characters long."
  }
}

variable "private_frontend_ip_configuration" {
  description = "Configuration for the frontend_ip_configuration that leverages a private IP address."
  type = object({
    explicit_name           = optional(string)
    ip_address_resource_id  = string
    address_allocation      = optional(string, "Static")
    subnet_resource_id      = string
    is_active_http_listener = optional(bool, false)
  })
  default = null
}

variable "public_frontend_ip_configuration" {
  description = "Configuration for the frontend_ip_configuration that leverages a public IP address. Might become nullable once https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-private-deployment leaves Preview."
  type = object({
    explicit_name           = optional(string)
    ip_address_resource_id  = string
    ip_address              = optional(string)
    is_active_http_listener = optional(bool, true)
  })

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/publicIPAddresses/.+$", var.public_frontend_ip_configuration.ip_address_resource_id))
    error_message = "The ip_address_resource_id must be a valid Azure public IP address resource ID."
  }

  validation {
    condition     = var.public_frontend_ip_configuration.ip_address == null || can(cidrhost(format("%s/32", var.public_frontend_ip_configuration.ip_address), 0))
    error_message = "The ip_address must be a valid IPv4 address."
  }
}

variable "resource_group" {
  description = "The resource group to deploy the gateway to."
  type = object({
    name     = string
    location = string
  })

  validation {
    condition     = length(var.resource_group.name) > 0 && length(var.resource_group.name) <= 90
    error_message = "The resource group name must be between 1 and 90 characters long."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.resource_group.name))
    error_message = "The resource group name can only contain alphanumeric characters, periods, underscores, and hyphens."
  }
}

variable "sku" {
  description = "The SKU of the gateway"
  type = object({
    name = string
    tier = string
  })
  default = {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  validation {
    condition = contains([
      "Standard_Small", "Standard_Medium", "Standard_Large",
      "Standard_v2", "WAF_Medium", "WAF_Large", "WAF_v2"
    ], var.sku.name)
    error_message = "The SKU name must be one of: Standard_Small, Standard_Medium, Standard_Large, Standard_v2, WAF_Medium, WAF_Large, WAF_v2."
  }

  validation {
    condition = contains([
      "Standard", "Standard_v2", "WAF", "WAF_v2"
    ], var.sku.tier)
    error_message = "The SKU tier must be one of: Standard, Standard_v2, WAF, WAF_v2."
  }

  validation {
    condition = (
      (var.sku.tier == "Standard" && contains(["Standard_Small", "Standard_Medium", "Standard_Large"], var.sku.name)) ||
      (var.sku.tier == "Standard_v2" && var.sku.name == "Standard_v2") ||
      (var.sku.tier == "WAF" && contains(["WAF_Medium", "WAF_Large"], var.sku.name)) ||
      (var.sku.tier == "WAF_v2" && var.sku.name == "WAF_v2")
    )
    error_message = "The SKU name and tier combination is invalid."
  }
}

variable "ssl_policy" {
  description = "SSL policy configuration"
  type = object({
    name = string
    type = string
  })
  default = {
    name = "AppGwSslPolicy20220101S"
    type = "Predefined"
  }
  nullable = false

  validation {
    condition     = contains(["Predefined", "Custom"], var.ssl_policy.type)
    error_message = "The ssl_policy.type must be either 'Predefined' or 'Custom'."
  }
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
}

variable "application_gateway_tags" {
  description = "Additional tags that apply only to the application gateway. These will be merged with the general tags variable."
  type        = map(string)
  default     = {}
}

variable "waf_policy_settings" {
  description = "The mode of the firewall policy (Prevention or Detection)"
  type = object({
    explicit_name               = optional(string)
    file_upload_enforcement     = optional(bool, true)
    file_upload_limit_in_mb     = optional(number, 4000)
    max_request_body_size_in_kb = optional(number, 2000)
    mode                        = optional(string, "Prevention")
    request_body_check          = optional(bool, true)
    request_body_enforcement    = optional(bool, true)
  })
  default = {
    file_upload_enforcement     = true
    file_upload_limit_in_mb     = 4000
    max_request_body_size_in_kb = 2000
    mode                        = "Prevention"
    request_body_check          = true
    request_body_enforcement    = true
  }
}

variable "waf_custom_rules_ip_allow_list" {
  description = "List of IP addresses or ranges which are allowed to pass the WAF. An empty list means all IPs are allowed."
  type        = list(string)
  default     = []
}

variable "waf_custom_rules_allow_https_challenges" {
  description = "Allow HTTP-01 challenges e.g.from Let's Encrypt."
  type        = bool
  default     = true
}

variable "waf_custom_rules_allow_monitoring_agents_to_probe_services" {
  description = "Allow monitoring agents to probe services."
  type = object({
    request_header_user_agent = string
    probe_path_equals         = list(string)
  })
  default = {
    request_header_user_agent = "Better Stack Better Uptime Bot Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
    probe_path_equals         = ["/probe", "/chat/api/health", "/knowledge-upload/api/health", "/sidebar/browser", "/debug/ready", "/", "/browser", "/chat/probe", "/ingestion/probe", "/api/probe", "/scope-management/probe", "/health"]
  }
}

variable "waf_custom_rules_allow_hosts" {
  description = "Allow monitoring agents to probe services."
  type = object({
    request_header_host = string
    host_contains       = list(string)
  })
  default = {
    request_header_host = "host"
    host_contains       = ["kubernetes.default.svc"]
  }
}

variable "waf_custom_rules_unique_access_to_paths_ip_restricted" {
  description = "Only allow certain IP matches to access selected paths. Passing no IP means all requests get blocked for these paths. Pass 0.0.0.0/0 to allow all IPs for the routes. The default blocks touchy routes as we ship secure by default."
  type = map(object({
    ip_allow_list    = list(string)
    path_begin_withs = list(string)
  }))
  default = {}
  validation {
    condition     = length(keys(var.waf_custom_rules_unique_access_to_paths_ip_restricted)) < 13 # this is limited due to the rule priority, can be increased if needed but then the rule priority must be adjusted
    error_message = "The number of unique access to paths IP restricted rules must be less than 13 or else the priorities overlap. If you need more, open an issue on GitHub."
  }
}

variable "waf_custom_rules_exempted_request_path_begin_withs" {
  # Unblock Ingestion Upload if the max request body size is greater than 2000KB
  # Note that this is now a green card to allowlist any URL.
  # This rules priority is 5, so it will be applied after all other rules (incl. e.g. IP-based rules).

  description = "The request URIs that are exempted from further checks. This is a workaround to allowlist certain URLs to bypass further blocking checks (in this case the body size)."
  type        = list(string)
  default = [
    # ‼️ Each line must have a use case rationale ‼️
    /**
    * Unblocks Ingestion Upload if the max request body size is greater than 2000KB (in this case here text ingestions with large bodies).
    * Currently Unique AI does not use multi-part uploads, therefore we must allow large body uploads for ingestion as the WAF limits otherwise block the request.
    * https://stackoverflow.com/questions/70975624/azure-web-application-firewall-waf-not-diferentiating-file-uploads-from-normal/72184077#72184077
    * https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-waf-request-size-limits
    */
    "/ingestion/v1/content", #
    /**
    * Unblocks Ingestion Upload if the max request body size is greater than 2000KB (in this case large bodies getting _streamed_ into the backing blob storage).
    * Currently Unique AI does not use multi-part uploads, therefore we must allow large body uploads for ingestion as the WAF limits otherwise block the request.
    * https://stackoverflow.com/questions/70975624/azure-web-application-firewall-waf-not-diferentiating-file-uploads-from-normal/72184077#72184077
    * https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-waf-request-size-limits
    */
    "/scoped/ingestion/upload", # Currently Unique AI does not use multi-part uploads, therefore we must allow large body uploads for ingestion as the WAF limits otherwise block the request.
    /**
    * Internal reference for mitigation: UN-12893
    */
    "/scim",
  ]
}


variable "waf_managed_rules" {
  description = "Default configuration for managed rules."
  type = object({
    owasp_rules = optional(list(
      object({
        rule_group_name = string
        rules = list(
          object({
            id      = string
            action  = optional(string, "AnomalyScoring")
            enabled = optional(bool, false)
          })
        )
      })
    ))
    bot_rules = optional(list(
      object({
        rule_group_name = string
        rules = list(
          object({
            id      = string
            action  = optional(string, "AnomalyScoring")
            enabled = optional(bool, false)
          })
        )
      })
    ))
    exclusions = optional(list(
      object({
        match_variable          = string
        selector_match_operator = string
        selector                = string
        excluded_rule_set = optional(object({
          type            = string
          version         = string
          excluded_rules  = optional(list(string), null)
          rule_group_name = string
        }), null)
      })
    ))
  })
  default = {
    owasp_rules = [
      {
        rule_group_name = "REQUEST-913-SCANNER-DETECTION"
        rules           = [{ id = "913101" }]
      },
      {
        rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
        rules           = [{ id = "920230" }, { id = "920271" }, { id = "920300" }, { id = "920320" }, { id = "920420" }]
      },
      {
        rule_group_name = "REQUEST-931-APPLICATION-ATTACK-RFI"
        rules           = [{ id = "931130" }]
      },
      {
        rule_group_name = "REQUEST-932-APPLICATION-ATTACK-RCE"
        rules           = [{ id = "932100" }, { id = "932105" }, { id = "932115" }, { id = "932130" }]
      },
      {
        rule_group_name = "REQUEST-933-APPLICATION-ATTACK-PHP"
        rules           = [{ id = "933160" }]
      },
      {
        rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
        rules = [
          { id = "942100" },
          { id = "942110" },
          { id = "942130" },
          { id = "942150" },
          { id = "942190" },
          { id = "942200" },
          { id = "942260" },
          { id = "942330" },
          { id = "942340" },
          { id = "942370" },
          { id = "942380" },
          { id = "942410" },
          { id = "942430" },
          { id = "942440" },
          { id = "942450" }
        ]
      }
    ]
    bot_rules = [
      {
        rule_group_name = "UnknownBots"
        rules = [
          {
            id      = "300300"
            action  = "Log"
            enabled = false
          },
          {
            id      = "300700"
            action  = "Log"
            enabled = false
          }
        ]
      }
    ]
    exclusions = [
      {
        match_variable          = "RequestArgNames"
        selector                = "variables.input.favicon,variables.input.logoHeader,variables.input.logoNavbar"
        selector_match_operator = "EqualsAny"
        excluded_rule_set = {
          type            = "OWASP"
          version         = "3.2"
          excluded_rules  = ["941130", "941170"]
          rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
        }
      },
      {
        match_variable          = "RequestArgNames"
        selector                = "variables.input.text,variables.text,messages.content,text"
        selector_match_operator = "EqualsAny"
        excluded_rule_set = {
          type            = "OWASP"
          version         = "3.2"
          rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
        }
      },
      {
        match_variable          = "RequestArgNames"
        selector                = "variables.input.text,variables.text,messages.content,text"
        selector_match_operator = "EqualsAny"
        excluded_rule_set = {
          type            = "OWASP"
          version         = "3.2"
          rule_group_name = "REQUEST-921-PROTOCOL-ATTACK"
        }
      },
      {
        match_variable          = "RequestArgNames"
        selector                = "variables.input.text,variables.text,variables.input.modules.upsert.create.configuration.systemPromptSearch"
        selector_match_operator = "EqualsAny"
        excluded_rule_set = {
          type            = "OWASP"
          version         = "3.2"
          rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
        }
      },
      {
        match_variable          = "RequestArgNames"
        selector                = "variables.input.text,variables.text,variables.input.modules.upsert.create.configuration.systemPromptSearch"
        selector_match_operator = "EqualsAny"
        excluded_rule_set = {
          type            = "OWASP"
          version         = "3.2"
          rule_group_name = "REQUEST-932-APPLICATION-ATTACK-RCE"
        }
      },
      {
        match_variable          = "RequestArgNames"
        selector                = "variables.input.text,variables.text,variables.input.modules.upsert.create.configuration.systemPromptSearch"
        selector_match_operator = "EqualsAny"
        excluded_rule_set = {
          type            = "OWASP"
          version         = "3.2"
          rule_group_name = "REQUEST-933-APPLICATION-ATTACK-PHP"
        }
      },
      {
        match_variable          = "RequestCookieNames"
        selector                = "__Secure-next-auth.session-token"
        selector_match_operator = "EqualsAny"
        excluded_rule_set = {
          type            = "OWASP"
          version         = "3.2"
          rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
        }
      },
      {
        match_variable          = "RequestCookieNames"
        selector                = "__Secure-next-auth.session-token"
        selector_match_operator = "EqualsAny"
        excluded_rule_set = {
          type            = "OWASP"
          version         = "3.2"
          rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
        }
      },
      {
        match_variable          = "RequestCookieNames"
        selector                = "__Host-uniqueid.useragent"
        selector_match_operator = "EqualsAny"
        excluded_rule_set = {
          type            = "OWASP"
          version         = "3.2"
          rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
        }
      },
      {
        match_variable          = "RequestCookieNames"
        selector                = "__Host-uniqueid.useragent"
        selector_match_operator = "EqualsAny"
        excluded_rule_set = {
          type            = "OWASP"
          version         = "3.2"
          rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
        }
      }
    ]
  }
}

variable "trusted_root_certificates" {
  description = "Configuration for trusted root certificates (e.g., for private CAs). Each certificate will be uploaded to the Application Gateway and can be referenced in backend HTTP settings."
  type = list(object({
    name             = string
    certificate_path = string
  }))
  default = []

  validation {
    condition = alltrue([
      for cert in var.trusted_root_certificates :
      length(cert.name) > 0 && length(cert.name) <= 80
    ])
    error_message = "Each trusted root certificate name must be between 1 and 80 characters long."
  }

  validation {
    condition = alltrue([
      for cert in var.trusted_root_certificates :
      can(regex("\\.(cer|crt|pem)$", cert.certificate_path))
    ])
    error_message = "Certificate file must have a .cer, .crt, or .pem extension."
  }
}

variable "zones" {
  description = "Specifies a list of Availability Zones in which this Application Gateway should be located. Changing this forces a new Application Gateway to be created."
  type        = list(string)
  default     = null
}

variable "metric_alerts" {
  description = "Map of metric alerts to create for the Application Gateway. By default includes 5xx error alerts. Set to {} to disable all default alerts."
  type = map(object({
    name                     = string
    description              = optional(string, "")
    severity                 = optional(number, 3)
    frequency                = optional(string, "PT5M")
    window_size              = optional(string, "PT15M")
    enabled                  = optional(bool, true)
    auto_mitigate            = optional(bool, true)
    target_resource_type     = optional(string, null)
    target_resource_location = optional(string, null)

    # Static criteria (one of criteria, dynamic_criteria, or application_insights_web_test_location_availability_criteria must be specified)
    criteria = optional(object({
      metric_namespace       = optional(string, "microsoft.network/applicationgateways")
      metric_name            = string
      aggregation            = string
      operator               = string
      threshold              = number
      skip_metric_validation = optional(bool, false)
      dimension = optional(list(object({
        name     = string
        operator = string # Include, Exclude, StartsWith
        values   = list(string)
      })), [])
    }))

    # Dynamic criteria (alternative to static criteria)
    dynamic_criteria = optional(object({
      metric_namespace         = optional(string, "microsoft.network/applicationgateways")
      metric_name              = string
      aggregation              = string
      operator                 = string
      alert_sensitivity        = optional(string, "Medium")
      evaluation_total_count   = optional(number, 4)
      evaluation_failure_count = optional(number, 4)
      ignore_data_before       = optional(string, null)
      skip_metric_validation   = optional(bool, false)
      dimension = optional(list(object({
        name     = string
        operator = string # Include, Exclude, StartsWith
        values   = list(string)
      })), [])
    }))

    # Application Insights web test location availability criteria (alternative to other criteria types)
    application_insights_web_test_location_availability_criteria = optional(object({
      web_test_id           = string
      component_id          = string
      failed_location_count = number
    }))

    # Actions configuration
    actions = optional(list(object({
      action_group_id    = string
      webhook_properties = optional(map(string), {})
    })), [])

    # Backward compatibility - will be deprecated in favor of actions
    action_group_ids = optional(list(string), [])
  }))
  default = {
    default_5xx_error_alert = {
      name        = "Application Gateway 5xx Error"
      description = "Alert when 5xx errors are above 100 for more than 1 hour"
      severity    = 1
      frequency   = "PT1M"
      window_size = "PT1H"
      enabled     = true
      criteria = {
        metric_namespace = "microsoft.network/applicationgateways"
        metric_name      = "ResponseStatus"
        aggregation      = "Total"
        operator         = "GreaterThan"
        threshold        = 100
        dimension = [{
          name     = "HttpStatusGroup"
          operator = "StartsWith"
          values = [
            "5xx",
          ]
        }]
      }
    }
  }

  validation {
    condition = alltrue([
      for k, v in var.metric_alerts :
      (v.criteria != null && v.dynamic_criteria == null && v.application_insights_web_test_location_availability_criteria == null) ||
      (v.criteria == null && v.dynamic_criteria != null && v.application_insights_web_test_location_availability_criteria == null) ||
      (v.criteria == null && v.dynamic_criteria == null && v.application_insights_web_test_location_availability_criteria != null)
    ])
    error_message = "Each metric alert must specify exactly one of 'criteria', 'dynamic_criteria', or 'application_insights_web_test_location_availability_criteria'."
  }

  validation {
    condition = alltrue([
      for k, v in var.metric_alerts :
      contains([0, 1, 2, 3, 4], v.severity)
    ])
    error_message = "Severity must be one of: 0 (Critical), 1 (Error), 2 (Warning), 3 (Informational), 4 (Verbose)."
  }

  validation {
    condition = alltrue([
      for k, v in var.metric_alerts :
      contains(["PT1M", "PT5M", "PT15M", "PT30M", "PT1H"], v.frequency)
    ])
    error_message = "Frequency must be one of: PT1M, PT5M, PT15M, PT30M, PT1H."
  }

  validation {
    condition = alltrue([
      for k, v in var.metric_alerts :
      contains(["PT1M", "PT5M", "PT15M", "PT30M", "PT1H", "PT6H", "PT12H", "P1D"], v.window_size)
    ])
    error_message = "Window size must be one of: PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H, P1D and must be greater than frequency."
  }
}

variable "metric_alerts_external_action_group_ids" {
  description = "List of external Action Group IDs to apply to all metric alerts that do not explicitly define actions or action_group_ids. If an alert defines actions or action_group_ids, those take precedence."
  type        = list(string)
  default     = []
}
