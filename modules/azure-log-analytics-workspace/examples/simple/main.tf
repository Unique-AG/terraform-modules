terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "azurerm_resource_group" "example" {
  location = "germanywestcentral"
  name     = "rg-law-example"
}

module "law" {
  source = "../../"

  location            = azurerm_resource_group.example.location
  name                = "uq-deer-prod"
  resource_group_name = azurerm_resource_group.example.name
}
