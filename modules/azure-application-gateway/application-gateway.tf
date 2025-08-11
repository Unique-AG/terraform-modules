locals {
  waf_enabled                           = var.sku.tier == "WAF_v2"
  backend_address_pool_name             = var.backend_address_pool.explicit_name != null ? var.backend_address_pool.explicit_name : "${var.name_prefix}-beap"
  backend_http_settings_name            = var.backend_http_settings.explicit_name != null ? var.backend_http_settings.explicit_name : "${var.name_prefix}-be-htst"
  http_listener_name                    = var.http_listener.explicit_name != null ? var.http_listener.explicit_name : "${var.name_prefix}-httplstn"
  public_frontend_ip_config_name        = var.public_frontend_ip_configuration.explicit_name != null ? var.public_frontend_ip_configuration.explicit_name : "${var.name_prefix}-feip"
  private_frontend_ip_config_name       = try(var.private_frontend_ip_configuration.explicit_name, "${var.name_prefix}-privatefeip")
  active_frontend_ip_configuration_name = var.public_frontend_ip_configuration.is_active_http_listener ? local.public_frontend_ip_config_name : local.private_frontend_ip_config_name
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

  # BACKEND ADDRESS POOL - Destination servers
  # Defines the backend servers/services that will receive the traffic
  backend_address_pool {
    name = local.backend_address_pool_name
  }

  # BACKEND HTTP SETTINGS - How to communicate with backend
  # Defines protocol, port, timeout, and session affinity settings for backend communication
  backend_http_settings {
    name                  = local.backend_http_settings_name
    cookie_based_affinity = var.backend_http_settings.cookie_based_affinity != null ? var.backend_http_settings.cookie_based_affinity : "Disabled"
    port                  = var.backend_http_settings.port != null ? var.backend_http_settings.port : 80
    protocol              = var.backend_http_settings.protocol != null ? var.backend_http_settings.protocol : "Http"
    request_timeout       = var.backend_http_settings.request_timeout != null ? var.backend_http_settings.request_timeout : 60
  }

  # HTTP LISTENER - Traffic reception point
  # Listens for incoming HTTP traffic on the specified frontend IP and port
  # Routes traffic based on whether private or public frontend is enabled
  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.active_frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port.explicit_name != null ? var.frontend_port.explicit_name : "${var.name_prefix}-feport"
    protocol                       = "Http"
  }

  # REQUEST ROUTING RULE - Traffic routing logic
  # Defines how incoming requests are routed from the listener to the backend
  # This is a basic rule that routes all traffic to the backend pool
  request_routing_rule {
    name                       = var.request_routing_rule.explicit_name != null ? var.request_routing_rule.explicit_name : "${var.name_prefix}-rqrt"
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
    http_listener_name         = local.http_listener_name
    priority                   = 19500
    rule_type                  = "Basic"
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

  name                       = try(var.monitor_diagnostic_setting.name, "log-${var.name_prefix}-appgw")
  target_resource_id         = azurerm_application_gateway.appgw.id
  log_analytics_workspace_id = var.monitor_diagnostic_setting.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.monitor_diagnostic_setting.enabled_log
    content {
      category_group = enabled_log.value.category_group
    }
  }
}
