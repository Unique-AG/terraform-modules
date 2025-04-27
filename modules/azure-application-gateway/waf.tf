locals {
  is_waf_v2              = var.gateway_sku == "WAF_v2" ? 1 : 0
  allow_https_challenges = local.is_waf_v2 == 1 && length(var.ip_waf_list) > 0 ? [1] : []
  public_ip_address      = var.public_ip_address_id == "" ? try(azurerm_public_ip.appgw[0].ip_address, null) : null
}

resource "azurerm_web_application_firewall_policy" "wafpolicy" {
  count               = local.is_waf_v2
  name                = var.waf_policy_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  policy_settings {
    enabled                     = true
    mode                        = var.gateway_mode
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 1024
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"

      dynamic "rule_group_override" {
        for_each = var.waf_policy_managed_rule_settings
        content {
          rule_group_name = rule_group_override.value.rule_group_name

          dynamic "rule" {
            for_each = rule_group_override.value.disabled_rule_ids
            content {
              action  = "AnomalyScoring"
              enabled = false
              id      = rule.value
            }
          }
        }
      }
    }
  }

  # Allow Let's Encrypt HTTP-01 challenges
  dynamic "custom_rules" {
    for_each = local.allow_https_challenges
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

  # Block unwanted IP addresses
  dynamic "custom_rules" {
    for_each = var.ip_waf_list
    content {
      name      = custom_rules.value.name
      priority  = 2 + index(var.ip_waf_list, custom_rules.value)
      rule_type = "MatchRule"

      match_conditions {
        match_variables {
          variable_name = "RemoteAddr"
        }
        operator           = "IPMatch"
        negation_condition = true
        match_values       = compact(concat(custom_rules.value.list, local.public_ip_address != null ? [local.public_ip_address] : []))
      }

      action = "Block"
    }
  }
}
