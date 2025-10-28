terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

variable "subscription_id" {
  type = string
}

resource "azurerm_resource_group" "postgresql_alerts_rg" {
  name     = "rg-postgresql-alerts-prod-swn-${random_string.resource_suffix.result}"
  location = "switzerlandnorth"
}



# Action group for notifications
resource "azurerm_monitor_action_group" "postgresql_alerts" {
  name                = "ag-postgresql-prod-alerts-${random_string.resource_suffix.result}"
  resource_group_name = azurerm_resource_group.postgresql_alerts_rg.name
  short_name          = "psqlalerts"

  email_receiver {
    name          = "dba-team"
    email_address = "dba-team@contoso.com"
  }

  email_receiver {
    name          = "platform-team"
    email_address = "platform-team@contoso.com"
  }
}

resource "random_password" "postgres_username" {
  length  = 16
  special = false
}

resource "random_password" "postgres_password" {
  length  = 32
  special = false
}

resource "random_string" "resource_suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
}

resource "random_string" "server_name" {
  length  = 8
  special = false
  upper   = false
}

# Production PostgreSQL with default alerts (CPU > 80% for 30min, Memory > 90% for 1h)
# module "postgresql_prod_defaults" {
#   source              = "../.."
#   admin_password      = random_password.postgres_password.result
#   administrator_login = random_password.postgres_username.result
#   name                = "psql-prod-default-${random_string.server_name.result}"
#   resource_group_name = azurerm_resource_group.postgresql_alerts_rg.name
#   location            = "switzerlandnorth"

#   # Default alerts are automatically enabled
#   # - CPU > 80% for 30min (severity: Warning)
#   # - Memory > 90% for 1h (severity: Error)
#   # No action groups configured, so alerts will only appear in Azure portal

#   tags = {
#     environment = "production"
#     purpose     = "default-alerts-demo"
#   }
# }

# Development PostgreSQL with alerts disabled
# module "postgresql_dev_no_alerts" {
#   source              = "../.."
#   admin_password      = random_password.postgres_password.result
#   administrator_login = random_password.postgres_username.result
#   name                = "psql-dev-no-alerts-${random_string.server_name.result}"
#   resource_group_name = azurerm_resource_group.postgresql_alerts_rg.name
#   location            = "switzerlandnorth"

#   # Disable all default alerts by setting empty map
#   metric_alerts = {}

#   tags = {
#     environment = "development"
#     purpose     = "no-alerts-demo"
#   }
# }

# # Production PostgreSQL with default alerts and notifications
# module "postgresql_prod_with_notifications" {
#   source              = "../.."
#   admin_password      = random_password.postgres_password.result
#   administrator_login = random_password.postgres_username.result
#   name                = "psql-prod-notify-${random_string.server_name.result}"
#   resource_group_name = azurerm_resource_group.postgresql_alerts_rg.name
#   location            = "switzerlandnorth"

#   # Override the default alerts to add action group notifications
#   metric_alerts = {
#     default_cpu_alert = {
#       name        = "PostgreSQL High CPU Usage"
#       description = "Alert when CPU usage is above 80% for more than 30 minutes"
#       severity    = 2
#       frequency   = "PT5M"
#       window_size = "PT30M"
#       enabled     = true
#       criteria = {
#         metric_name = "cpu_percent"
#         aggregation = "Average"
#         operator    = "GreaterThan"
#         threshold   = 80
#       }
#       action_group_ids = [azurerm_monitor_action_group.postgresql_alerts.id]
#     }

#     default_memory_alert = {
#       name        = "PostgreSQL High Memory Usage"
#       description = "Alert when memory usage is above 90% for more than 1 hour"
#       severity    = 1
#       frequency   = "PT15M"
#       window_size = "PT1H"
#       enabled     = true
#       criteria = {
#         metric_name = "memory_percent"
#         aggregation = "Average"
#         operator    = "GreaterThan"
#         threshold   = 90
#       }
#       action_group_ids = [azurerm_monitor_action_group.postgresql_alerts.id]
#     }
#   }

#   tags = {
#     environment = "production"
#     purpose     = "defaults-with-notifications"
#   }
# }

# Production PostgreSQL with default alerts using external Action Group fallback
module "postgresql_prod_defaults_with_external_action_group" {
  source              = "../.."
  admin_password      = random_password.postgres_password.result
  administrator_login = random_password.postgres_username.result
  name                = "psql-prod-default-extag-${random_string.server_name.result}"
  resource_group_name = azurerm_resource_group.postgresql_alerts_rg.name
  location            = "switzerlandnorth"

  # Fallback Action Group applied to all alerts that don't define their own
  metric_alerts_external_action_group_ids = [
    azurerm_monitor_action_group.postgresql_alerts.id
  ]

  tags = {
    environment = "production"
    purpose     = "default-alerts-external-action-group"
  }
}

# # Staging PostgreSQL with custom alert thresholds
# module "postgresql_staging_custom" {
#   source              = "../.."
#   admin_password      = random_password.postgres_password.result
#   administrator_login = random_password.postgres_username.result
#   name                = "psql-stg-custom-${random_string.server_name.result}"
#   resource_group_name = azurerm_resource_group.postgresql_alerts_rg.name
#   location            = "switzerlandnorth"

#   # Customize the default thresholds and add more alerts
#   metric_alerts = {
#     # Lower CPU threshold for development environment
#     custom_cpu_alert = {
#       name        = "PostgreSQL High CPU Usage (Custom)"
#       description = "Alert when CPU usage is above 70% for more than 15 minutes"
#       severity    = 3
#       frequency   = "PT5M"
#       window_size = "PT15M"
#       enabled     = true
#       criteria = {
#         metric_name = "cpu_percent"
#         aggregation = "Average"
#         operator    = "GreaterThan"
#         threshold   = 70
#       }
#       action_group_ids = [azurerm_monitor_action_group.postgresql_alerts.id]
#     }

#     # Keep default memory alert but with notifications
#     default_memory_alert = {
#       name        = "PostgreSQL High Memory Usage"
#       description = "Alert when memory usage is above 90% for more than 1 hour"
#       severity    = 1
#       frequency   = "PT15M"
#       window_size = "PT1H"
#       enabled     = true
#       criteria = {
#         metric_name = "memory_percent"
#         aggregation = "Average"
#         operator    = "GreaterThan"
#         threshold   = 90
#       }
#       action_group_ids = [azurerm_monitor_action_group.postgresql_alerts.id]
#     }

#     # Add connection monitoring
#     connection_alert = {
#       name        = "PostgreSQL High Connection Count"
#       description = "Alert when active connections exceed 300"
#       severity    = 2
#       frequency   = "PT5M"
#       window_size = "PT15M"
#       enabled     = true
#       criteria = {
#         metric_name = "active_connections"
#         aggregation = "Average"
#         operator    = "GreaterThan"
#         threshold   = 300
#       }
#       action_group_ids = [azurerm_monitor_action_group.postgresql_alerts.id]
#     }
#   }

#   tags = {
#     environment = "staging"
#     purpose     = "custom-thresholds-demo"
#   }
# }