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

  # Event Hub can be in the same or different subscription
  eventhub = {
    name                  = "eventhub-001"
    authorization_rule_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rg-eventhub-example/providers/Microsoft.EventHub/namespaces/eventhub-namespace-001/authorizationRules/eventhub-namespace-001-send"
  }
}
