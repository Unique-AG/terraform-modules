resource "azurerm_resource_group" "eventhub" {
  name     = "rg-eventhub-example"
  location = "switzerlandnorth"
}

module "eventhub" {
  source = "../.."

  location            = azurerm_resource_group.eventhub.location
  resource_group_name = azurerm_resource_group.eventhub.name
  tags = {
    environment = "demo"
  }
}
