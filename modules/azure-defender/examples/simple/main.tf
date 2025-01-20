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

}
