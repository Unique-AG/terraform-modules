terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-activity-log-export-example"
  location = "East US"
}

module "activity_log_export" {
  source = "../../"

  name            = "activity-log-to-eventhub"
  subscription_id = data.azurerm_subscription.current.subscription_id

  eventhub = {
    name                    = "eventhub-001"
    resource_group_name     = "rg-eventhub-example"
    namespace_name          = "eventhub-namespace-001"
    authorization_rule_name = "eventhub-namespace-001-send"
  }
}
