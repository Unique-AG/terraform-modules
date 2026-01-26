terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}


data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-defender-export-example"
  location = "East US"
}

# Data source to retrieve the connection string for the Event Hub authorization rule
# This can be in the same or different subscription (requires appropriate provider configuration)
data "azurerm_eventhub_namespace_authorization_rule" "send" {
  name                = "eventhub-namespace-001-send"
  resource_group_name = "rg-eventhub-example"
  namespace_name      = "eventhub-namespace-001"
}

module "defender" {
  source = "../../"

  subscription_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"

  security_contact_settings = {
    email = "security@example.com"
  }

  cloud_posture_defender_settings = {
    tier = "Standard"
  }

  storage_accounts_defender_settings = {
    tier = "Standard"
  }

  eventhub_export = {
    name                = "defender-to-eventhub"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    # Event Hub can be in the same or different subscription
    eventhub = {
      id                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/rg-eventhub-example/providers/Microsoft.EventHub/namespaces/eventhub-namespace-001/eventhubs/eventhub-001"
      connection_string = data.azurerm_eventhub_namespace_authorization_rule.send.primary_connection_string
    }
    # sources defaults to both alerts and assessments with standard severity/status filters
    # To customize, override the sources:
    # sources = {
    #   alert = {
    #     event_source  = "Alerts"
    #     property_path = "properties.metadata.severity"
    #     labels        = ["High", "Medium"]
    #   }
    #   assessment = {
    #     event_source  = "Assessments"
    #     property_path = "properties.status.code"
    #     labels        = ["Unhealthy"]
    #   }
    #   secure_score = {
    #     event_source = "SecureScores"
    #     # SecureScores don't support filtering, so no property_path or labels needed
    #   }
    # }
  }
}