variable "subscription_id" {
  type = string
}

variable "break_glass_group" {
  description = "Entra group whose members can log in as server administrators."
  type = object({
    object_id    = string
    display_name = string
  })
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "switzerlandnorth"
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "id-example-app"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "random_password" "postgres_username" {
  length  = 16
  special = false
  numeric = false
}

resource "random_password" "postgres_password" {
  length  = 32
  special = false
}

resource "random_string" "server_name" {
  length  = 8
  special = false
  upper   = false
}

module "apfs" {
  source              = "../.."
  admin_password      = random_password.postgres_password.result
  administrator_login = random_password.postgres_username.result
  name                = "my-postgresql-server-${random_string.server_name.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  authentication = {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  entra_administrators = {
    app = {
      object_id      = azurerm_user_assigned_identity.app.principal_id
      principal_name = azurerm_user_assigned_identity.app.name
      principal_type = "ServicePrincipal"
    }
    break-glass = {
      object_id      = var.break_glass_group.object_id
      principal_name = var.break_glass_group.display_name
      principal_type = "Group"
    }
  }

  metric_alerts_external_action_group_ids = []

  tags = {
    environment = "example"
  }
}
