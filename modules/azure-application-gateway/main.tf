locals {
  waf_enabled                           = var.sku.tier == "WAF_v2"
  public_frontend_ip_config_name        = var.public_frontend_ip_configuration.explicit_name != null ? var.public_frontend_ip_configuration.explicit_name : "${var.name_prefix}-feip"
  private_frontend_ip_config_name       = try(var.private_frontend_ip_configuration.explicit_name, "${var.name_prefix}-privatefeip")
  active_frontend_ip_configuration_name = var.public_frontend_ip_configuration.is_active_http_listener ? local.public_frontend_ip_config_name : local.private_frontend_ip_config_name
}

resource "azurerm_web_application_firewall_policy" "wafpolicy" {
  count               = local.waf_enabled ? 1 : 0
  name                = var.waf_policy_settings.explicit_name != null ? var.waf_policy_settings.explicit_name : "${var.name_prefix}-wafpolicy"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  policy_settings {
    enabled = true
    mode    = try(var.waf_policy_settings.mode, "Prevention")

    file_upload_enforcement     = try(var.waf_policy_settings.file_upload_enforcement, true)
    file_upload_limit_in_mb     = try(var.waf_policy_settings.file_upload_limit_in_mb, 512)
    request_body_check          = try(var.waf_policy_settings.request_body_check, true)
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

  # (3 to 14)
  # Restrict certain routes to certain IP addresses
  dynamic "custom_rules" {
    for_each = var.waf_custom_rules_unique_access_to_paths_ip_restricted
    content {
      name      = "RestrictAccessTo${replace(title(custom_rules.key), "-", "")}"
      priority  = 3 + index(keys(var.waf_custom_rules_unique_access_to_paths_ip_restricted), custom_rules.key)
      rule_type = "MatchRule"
      action    = "Block"

      # Only create IP match condition if there are IPs to allow
      dynamic "match_conditions" {
        for_each = length(custom_rules.value.ip_allow_list) > 0 ? [1] : []
        content {
          match_variables {
            variable_name = "RemoteAddr"
          }
          operator           = "IPMatch"
          negation_condition = true
          match_values       = custom_rules.value.ip_allow_list
        }
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

  # (15)
  # Only allow listed IP addresses and ranges for the rest
  dynamic "custom_rules" {
    for_each = length(var.waf_custom_rules_ip_allow_list) > 0 ? [1] : []
    content {
      name      = "BlockUnwantedIPs"
      priority  = 15
      rule_type = "MatchRule"
      action    = "Block" # condition is negated, we block everything that does _not_ IPMatch

      match_conditions {
        match_variables {
          variable_name = "RemoteAddr"
        }
        operator           = "IPMatch"
        negation_condition = true
        match_values       = compact(var.waf_custom_rules_ip_allow_list)
      }
    }
  }

  # (16)
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
  dynamic "custom_rules" {
    for_each = var.waf_custom_rules_allow_hosts != null ? [1] : []
    content {
      name      = "AllowSpecificHosts"
      priority  = 99
      rule_type = "MatchRule"
      action    = "Allow"

      match_conditions {
        match_variables {
          variable_name = "RequestHeaders"
          selector      = var.waf_custom_rules_allow_hosts.request_header_host
        }
        operator           = "Contains"
        negation_condition = false
        match_values       = var.waf_custom_rules_allow_hosts.host_contains
      }
    }
  }

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
  lifecycle {
    create_before_destroy = true
  }
}


resource "azurerm_application_gateway" "appgw" {
  enable_http2        = true
  firewall_policy_id  = local.waf_enabled ? azurerm_web_application_firewall_policy.wafpolicy[0].id : null
  location            = var.resource_group.location
  name                = var.explicit_name != null ? var.explicit_name : "${var.name_prefix}-appgw"
  resource_group_name = var.resource_group.name
  tags                = var.tags
  zones               = var.zones

  # GLOBAL CONFIGURATION - Applied to all traffic
  # Controls how the Application Gateway handles request/response buffering
  global {
    request_buffering_enabled  = var.global_request_buffering_enabled
    response_buffering_enabled = var.global_response_buffering_enabled
  }

  # SKU CONFIGURATION - Defines the tier and capabilities
  # Determines performance, features, and pricing tier
  sku {
    name = var.sku.name
    tier = var.sku.tier
  }

  # AUTOSCALE CONFIGURATION - Performance scaling
  # Automatically scales the Application Gateway based on traffic load
  autoscale_configuration {
    min_capacity = var.autoscale_configuration.min_capacity
    max_capacity = var.autoscale_configuration.max_capacity
  }

  # SSL POLICY - Security configuration
  # Defines SSL/TLS security policies for HTTPS traffic
  ssl_policy {
    policy_name = var.ssl_policy.name
    policy_type = var.ssl_policy.type
  }

  # GATEWAY IP CONFIGURATION - Network connectivity
  # Defines which subnet the Application Gateway will be deployed in and under which name.
  gateway_ip_configuration {
    name      = var.gateway_ip_configuration.explicit_name != null ? var.gateway_ip_configuration.explicit_name : "${var.name_prefix}-gwip"
    subnet_id = var.gateway_ip_configuration.subnet_resource_id
  }

  # FRONTEND PORT - Port where traffic is received
  # Defines the port (80) that the Application Gateway listens on for incoming traffic
  frontend_port {
    name = var.frontend_port.explicit_name != null ? var.frontend_port.explicit_name : "${var.name_prefix}-feport"
    port = var.frontend_port.port != null ? var.frontend_port.port : 80
  }

  # PUBLIC FRONTEND IP CONFIGURATION - Internet-facing endpoint
  # Associates the Application Gateway with a public IP address for internet access
  frontend_ip_configuration {
    name                 = local.public_frontend_ip_config_name
    public_ip_address_id = var.public_frontend_ip_configuration.ip_address_resource_id
  }

  # PRIVATE FRONTEND IP CONFIGURATION - Internal endpoint
  # Provides internal access to the Application Gateway within the VNet
  dynamic "frontend_ip_configuration" {
    for_each = var.private_frontend_ip_configuration != null ? [1] : []
    content {
      name                          = local.private_frontend_ip_config_name
      private_ip_address            = var.private_frontend_ip_configuration.ip_address_resource_id
      private_ip_address_allocation = var.private_frontend_ip_configuration.address_allocation != null ? var.private_frontend_ip_configuration.address_allocation : "Static"
      subnet_id                     = var.private_frontend_ip_configuration.subnet_resource_id
    }
  }

  # TRUSTED ROOT CERTIFICATES - Private CA certificates
  # Uploads private CA root certificates for validating backend HTTPS connections
  dynamic "trusted_root_certificate" {
    for_each = var.trusted_root_certificates
    content {
      name = trusted_root_certificate.value.name
      data = filebase64(trusted_root_certificate.value.certificate_path)
    }
  }

  # BACKEND ADDRESS POOL - Destination servers
  # Defines the backend servers/services that will receive the traffic
  # 🔧 Fully controlled by AGIC, only here to satisfy initial terraform
  backend_address_pool {
    name = "${var.name_prefix}-beap"
  }

  # BACKEND HTTP SETTINGS - How to communicate with backend
  # Defines protocol, port, timeout, and session affinity settings for backend communication
  # 🔧 Fully controlled by AGIC, only here to satisfy initial terraform
  backend_http_settings {
    name                  = "${var.name_prefix}-be-htst"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
  }

  # HTTP LISTENER - Traffic reception point
  # Listens for incoming HTTP traffic on the specified frontend IP and port
  # Routes traffic based on whether private or public frontend is enabled
  # 🔧 Fully controlled by AGIC, only here to satisfy initial terraform
  http_listener {
    name                           = "${var.name_prefix}-httplstn"
    frontend_ip_configuration_name = local.active_frontend_ip_configuration_name
    frontend_port_name             = "${var.name_prefix}-feport"
    protocol                       = "Https"
  }

  # REQUEST ROUTING RULE - Traffic routing logic
  # Defines how incoming requests are routed from the listener to the backend
  # 🔧 Fully controlled by AGIC, only here to satisfy initial terraform
  request_routing_rule {
    name               = "${var.name_prefix}-rqrt"
    http_listener_name = "${var.name_prefix}-httplstn"
    rule_type          = "Basic"
  }

  # REWRITE RULE SET - Rewrites requests and responses in flight
  # Modifies response headers to add security headers and remove sensitive information
  rewrite_rule_set {
    name = "security-headers"

    # Adds HSTS header for security
    rewrite_rule {
      name          = "set-hsts-header"
      rule_sequence = 100

      response_header_configuration {
        header_name  = "Strict-Transport-Security"
        header_value = "max-age=31536000; includeSubDomains"
      }
    }
    # Adds X-Content-Type-Options header
    rewrite_rule {
      name          = "set-nosniff-header"
      rule_sequence = 101

      response_header_configuration {
        header_name  = "X-Content-Type-Options"
        header_value = "nosniff"
      }
    }
    # Adds XSS protection header
    rewrite_rule {
      name          = "set-xss-header"
      rule_sequence = 102

      response_header_configuration {
        header_name  = "X-XSS-Protection"
        header_value = "1; mode=block"
      }
    }
    # Adds referrer policy header
    rewrite_rule {
      name          = "set-ref-header"
      rule_sequence = 103

      response_header_configuration {
        header_name  = "Referrer-Policy"
        header_value = "same-origin"
      }
    }
    # Removes server header for security
    rewrite_rule {
      name          = "delete-server-header"
      rule_sequence = 104

      response_header_configuration {
        header_name  = "Server"
        header_value = ""
      }
    }
  }

  # LIFECYCLE CONFIGURATION - Terraform state management
  # Prevents Terraform from managing certain settings that are controlled by external systems
  # (like Kubernetes Ingress Controller)
  lifecycle {
    ignore_changes = [
      # these settings are all ignored as they are controlled by the Application Gateway Ingress Controller
      backend_http_settings,
      backend_address_pool,
      probe,
      frontend_port,
      http_listener,
      redirect_configuration,
      request_routing_rule,
      ssl_certificate,
      url_path_map,
      tags["ingress-for-aks-cluster-id"],
      tags["managed-by-k8s-ingress"]
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "agw_diagnostic" {
  count = var.monitor_diagnostic_setting != null ? 1 : 0

  name                       = var.monitor_diagnostic_setting != null ? (var.monitor_diagnostic_setting.explicit_name != null ? var.monitor_diagnostic_setting.explicit_name : "log-${var.name_prefix}-appgw") : "log-${var.name_prefix}-appgw"
  target_resource_id         = azurerm_application_gateway.appgw.id
  log_analytics_workspace_id = var.monitor_diagnostic_setting.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.monitor_diagnostic_setting.enabled_log != null ? var.monitor_diagnostic_setting.enabled_log : []
    content {
      category_group = enabled_log.value.category_group
    }
  }
}
