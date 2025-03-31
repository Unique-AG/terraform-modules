locals {
  app_gw_name                     = var.application_gateway_name == null ? "${var.name_prefix}-appgw" : var.application_gateway_name
  frontend_ip_config_name         = var.frontend_ip_config_name == null ? "${var.name_prefix}-feip" : var.frontend_ip_config_name
  frontend_ip_private_config_name = var.frontend_ip_private_config_name == null ? "${var.name_prefix}-privatefeip" : var.frontend_ip_private_config_name
  http_listener_name              = var.http_listener_name == null ? "${var.name_prefix}-httplstn" : var.http_listener_name
  backend_http_settings_name      = var.backend_http_settings_name == null ? "${var.name_prefix}-be-htst" : var.backend_http_settings_name
  routing_rule_name               = var.routing_rule_name == null ? "${var.name_prefix}-rqrt" : var.routing_rule_name
  backend_address_pool_name       = var.backend_address_pool_name == null ? "${var.name_prefix}-beap" : var.backend_address_pool_name
  frontend_port_name              = var.frontend_port_name == null ? "${var.name_prefix}-feport" : var.frontend_port_name
  gw_ip_config_name               = var.gw_ip_config_name == null ? "${var.name_prefix}-gwip" : var.gw_ip_config_name
  agw_diagnostic_name             = var.agw_diagnostic_name == null ? "log-${var.name_prefix}-appgw" : var.agw_diagnostic_name
  firewall_policy_id              = var.gateway_sku == "WAF_v2" ? azurerm_web_application_firewall_policy.wafpolicy[0].id : null
}

resource "azurerm_application_gateway" "appgw" {
  name                = local.app_gw_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  enable_http2        = true

  global {
    request_buffering_enabled  = var.request_buffering_enabled
    response_buffering_enabled = var.response_buffering_enabled
  }

  sku {
    name = var.gateway_sku
    tier = var.gateway_tier
  }

  gateway_ip_configuration {
    name      = local.gw_ip_config_name
    subnet_id = var.subnet_appgw
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.public_ip_enabled ? [1] : []
    content {
      name                 = local.frontend_ip_config_name
      public_ip_address_id = var.public_ip_address_id != "" ? var.public_ip_address_id : try(azurerm_public_ip.appgw[0].id, null)
    }
  }

  frontend_ip_configuration {
    name                          = local.frontend_ip_private_config_name
    private_ip_address            = var.private_ip # 10.201.3.6
    private_ip_address_allocation = "Static"
    subnet_id                     = var.subnet_appgw
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  autoscale_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  backend_http_settings {
    name                  = local.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_config_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.routing_rule_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
    http_listener_name         = local.http_listener_name
    priority                   = 19500
    rule_type                  = "Basic"
  }

  ssl_policy {
    policy_name = var.ssl_policy_name
    policy_type = var.ssl_policy_type
  }

  rewrite_rule_set {
    name = "security-headers"

    rewrite_rule {
      name          = "set-hsts-header"
      rule_sequence = 100

      response_header_configuration {
        header_name  = "Strict-Transport-Security"
        header_value = "max-age=31536000; includeSubDomains"
      }
    }
    rewrite_rule {
      name          = "set-nosniff-header"
      rule_sequence = 101

      response_header_configuration {
        header_name  = "X-Content-Type-Options"
        header_value = "nosniff"
      }
    }
    rewrite_rule {
      name          = "set-xss-header"
      rule_sequence = 102

      response_header_configuration {
        header_name  = "X-XSS-Protection"
        header_value = "1; mode=block"
      }
    }
    rewrite_rule {
      name          = "set-ref-header"
      rule_sequence = 103

      response_header_configuration {
        header_name  = "Referrer-Policy"
        header_value = "same-origin"
      }
    }
    rewrite_rule {
      name          = "delete-server-header"
      rule_sequence = 104

      response_header_configuration {
        header_name  = "Server"
        header_value = ""
      }
    }
  }

  firewall_policy_id = local.firewall_policy_id
  tags               = var.tags

  lifecycle {
    ignore_changes = [
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
  count                      = var.log_analytics_workspace_id != null && var.log_analytics_workspace_id != "" ? 1 : 0
  name                       = local.agw_diagnostic_name
  target_resource_id         = azurerm_application_gateway.appgw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}
