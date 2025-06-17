terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

data "azurerm_subscription" "current" {}

module "defender" {
  source          = "../.."
  subscription_id = data.azurerm_subscription.current.id
  security_contact_settings = {
    email = "example@example.com"
  }
  storage_accounts_defender_settings = {
    extensions = [
      {
        name = "OnUploadMalwareScanning"
        additional_extension_properties = {
          CapGBPerMonthPerStorageAccount = "50"
        }
      },
      {
        name = "SensitiveDataDiscovery"
      }
    ]
  }
  virtual_machines_defender_settings = {
    tier = "Free"
  }
  ai_defender_settings = {
    tier = "Standard"
  }
}