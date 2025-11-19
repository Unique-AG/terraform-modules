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
    eventhub = {
      name                    = "eventhub-001"
      resource_group_name     = "rg-eventhub-example"
      namespace_name          = "eventhub-namespace-001"
      authorization_rule_name = "eventhub-namespace-001-send"
    }
    export_alerts        = true
    export_assessments   = true
    export_secure_scores = false
    alert_severities     = ["High", "Medium"]
    assessment_statuses  = ["Unhealthy"]
  }
}