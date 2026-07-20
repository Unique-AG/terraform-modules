terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-defender-workspace-example"
  location = "Switzerland North"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-defender-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "defender" {
  source          = "../.."
  subscription_id = data.azurerm_subscription.current.id
  security_contact_settings = {
    email = "example@example.com"
  }
  # Routes Defender data to this workspace instead of the auto-provisioned
  # DefaultWorkspace-<subscription-id>-<geo> in DefaultResourceGroup-<geo>
  workspace_settings = {
    workspace_id = azurerm_log_analytics_workspace.example.id
  }
}
