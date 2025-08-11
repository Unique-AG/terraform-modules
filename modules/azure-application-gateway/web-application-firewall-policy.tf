variable "waf_policy_settings" {
  description = "The mode of the firewall policy (Prevention or Detection)"
  type = object({
    explicit_name               = optional(string)
    mode                        = optional(string, "Prevention")
    request_body_check          = optional(bool, true)
    file_upload_limit_in_mb     = optional(number, 512)
    max_request_body_size_in_kb = optional(number, 2000)
    request_body_enforcement    = optional(bool, true)
  })
  default = {
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 512
    max_request_body_size_in_kb = 2000
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
  nullable = true
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
  nullable = true
  default = {
    request_header_host = "host"
    host_contains       = ["kubernetes.default.svc"]
  }
}

variable "waf_custom_rules_unique_access_to_paths_ip_restricted" {
  description = "Only allow certain IP matches to access selected paths. Passing no IP means all requests get blocked for these paths."
  type = map(object({
    ip_allow_list    = list(string)
    path_begin_withs = list(string)
  }))
  default = {
    chat-export = {
      ip_allow_list    = []
      path_begin_withs = ["/chat/analytics/user-chat-export"]
    }
  }
  validation {
    condition     = length(keys(var.waf_custom_rules_unique_access_to_paths_ip_restricted)) < 13
    error_message = "The number of unique access to paths IP restricted rules must be less than 13 or else the priorities overlap. If you need more, open an issue on GitHub."
  }
}

variable "waf_custom_rules_exempted_request_path_begin_withs" {
  # Unblock Ingestion Upload if the max request body size is greater than 2000KB
  # Note that this is now a green card to allowlist any URL.
  # This rules priority is 5, so it will be applied after all other rules (incl. e.g. IP-based rules).
  # https://stackoverflow.com/questions/70975624/azure-web-application-firewall-waf-not-diferentiating-file-uploads-from-normal/72184077#72184077
  # https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-waf-request-size-limits
  description = "The request URIs that are exempted from further checks. This is a workaround to allowlist certain URLs to bypass further blocking checks (in this case the body size)."
  type        = list(string)
  default     = ["/scoped/ingestion/upload", "/ingestion/v1/content"]
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
        rules           = [{ id = "920230" }, { id = "920300" }, { id = "920320" }, { id = "920420" }]
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
        selector                = "variables.input.text,variables.text"
        selector_match_operator = "EqualsAny"
        excluded_rule_set = {
          type            = "OWASP"
          version         = "3.2"
          rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
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
          rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
        }
      }
    ]
  }
}

resource "azurerm_web_application_firewall_policy" "wafpolicy" {
  count               = local.waf_enabled ? 1 : 0
  name                = var.waf_policy_settings.explicit_name != null ? var.waf_policy_settings.explicit_name : "${var.name_prefix}-wafpolicy"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  policy_settings {
    enabled                     = true
    mode                        = try(var.waf_policy_settings.mode, "Prevention")
    request_body_check          = try(var.waf_policy_settings.request_body_check, true)
    file_upload_limit_in_mb     = try(var.waf_policy_settings.file_upload_limit_in_mb, 512)
    max_request_body_size_in_kb = try(var.waf_policy_settings.max_request_body_size_in_kb, 2000)
    request_body_enforcement    = try(var.waf_policy_settings.request_body_enforcement, true)
  }

  # (1)
  # Allow Let's Encrypt HTTP-01 challenges
  dynamic "custom_rules" {
    for_each = var.waf_custom_rules_allow_https_challenges ? [1] : []
    content {
      name      = "AllowHttpsChallenges"
      priority  = 1
      rule_type = "MatchRule"
      action    = "Allow"

      match_conditions {
        match_variables {
          variable_name = "RequestHeaders"
          selector      = "User-Agent"
        }
        operator           = "Contains"
        negation_condition = false
        match_values       = ["https://www.letsencrypt.org"]
        transforms         = ["Lowercase"]
      }

      match_conditions {
        match_variables {
          variable_name = "RequestUri"
        }
        operator           = "BeginsWith"
        negation_condition = false
        match_values       = ["/.well-known/acme-challenge/"]
        transforms         = ["Lowercase"]
      }
    }
  }

  # (2)
  # Allow Monitoring Agents to probe services
  dynamic "custom_rules" {
    for_each = var.waf_custom_rules_allow_monitoring_agents_to_probe_services != null ? [1] : []
    content {
      name      = "AllowMonitoringAgentsToProbeServices"
      priority  = 2
      rule_type = "MatchRule"
      action    = "Allow"

      match_conditions {
        match_variables {
          variable_name = "RequestHeaders"
          selector      = "User-Agent"
        }
        operator           = "Equal"
        negation_condition = false
        match_values       = [var.waf_custom_rules_allow_monitoring_agents_to_probe_services.request_header_user_agent]
      }

      match_conditions {
        match_variables {
          variable_name = "RequestUri"
        }
        operator           = "Equal"
        negation_condition = false
        match_values       = toset(var.waf_custom_rules_allow_monitoring_agents_to_probe_services.probe_path_equals)
        transforms         = ["Lowercase"]
      }
    }
  }

  # (3)
  # Restrict certain routes to certain IP addresses
  dynamic "custom_rules" {
    for_each = var.waf_custom_rules_unique_access_to_paths_ip_restricted
    content {
      name      = "RestrictAccessTo${replace(title(custom_rules.key), "-", "")}"
      priority  = 3 + index(keys(var.waf_custom_rules_unique_access_to_paths_ip_restricted), custom_rules.key)
      rule_type = "MatchRule"
      action    = "Block"

      match_conditions {
        match_variables {
          variable_name = "RemoteAddr"
        }
        operator           = "IPMatch"
        negation_condition = length(custom_rules.value.ip_allow_list) > 0
        match_values       = length(custom_rules.value.ip_allow_list) > 0 ? custom_rules.value.ip_allow_list : []
      }

      match_conditions {
        match_variables {
          variable_name = "RequestUri"
        }
        operator           = "BeginsWith"
        negation_condition = false
        match_values       = custom_rules.value.path_begin_withs
        transforms         = ["Lowercase"]
      }
    }
  }

  # (4)
  # Only allow listed IP addresses and ranges for the rest
  dynamic "custom_rules" {
    for_each = length(var.waf_custom_rules_ip_allow_list) > 0 ? [1] : []
    content {
      name      = "BlockUnwantedIPs"
      priority  = 15
      rule_type = "MatchRule"
      action    = "Block"

      match_conditions {
        match_variables {
          variable_name = "RemoteAddr"
        }
        operator           = "IPMatch"
        negation_condition = true
        match_values       = compact(concat(var.waf_custom_rules_ip_allow_list, [var.public_ip_address.ip_address]))
      }
    }
  }

  # (5)
  # Allow certain URLs to be directly accessed without further checks (circumventing body enforcement until Unique AI properly handles multi-part uploads)
  dynamic "custom_rules" {
    for_each = length(var.waf_custom_rules_exempted_request_path_begin_withs) > 0 ? [1] : []
    content {
      name      = "FurtherCheckingExemptedURIs"
      priority  = 16
      rule_type = "MatchRule"
      action    = "Allow"

      match_conditions {
        match_variables {
          variable_name = "RequestUri"
        }
        operator     = "BeginsWith"
        match_values = var.waf_custom_rules_exempted_request_path_begin_withs
        transforms   = ["Lowercase"]
      }
    }
  }

  # (99)
  # Allow certain host headers to pass
  # TODO

  # (#)
  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"

      dynamic "rule_group_override" {
        for_each = var.waf_managed_rules.owasp_rules
        content {
          rule_group_name = rule_group_override.value.rule_group_name
          dynamic "rule" {
            for_each = rule_group_override.value.rules
            content {
              id      = rule.value.id
              action  = rule.value.action
              enabled = rule.value.enabled
            }
          }
        }
      }
    }
    managed_rule_set {
      type    = "Microsoft_BotManagerRuleSet"
      version = "1.0"

      dynamic "rule_group_override" {
        for_each = var.waf_managed_rules.bot_rules
        content {
          rule_group_name = rule_group_override.value.rule_group_name
          dynamic "rule" {
            for_each = rule_group_override.value.rules
            content {
              id      = rule.value.id
              action  = rule.value.action
              enabled = rule.value.enabled
            }
          }
        }
      }
    }

    dynamic "exclusion" {
      for_each = var.waf_managed_rules.exclusions
      content {
        match_variable          = exclusion.value.match_variable
        selector_match_operator = exclusion.value.selector_match_operator
        selector                = exclusion.value.selector

        excluded_rule_set {
          type    = exclusion.value.excluded_rule_set.type
          version = exclusion.value.excluded_rule_set.version
          rule_group {
            rule_group_name = exclusion.value.excluded_rule_set.rule_group_name
            excluded_rules  = exclusion.value.excluded_rule_set.excluded_rules
          }
        }
      }
    }
  }
}
