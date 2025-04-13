resource "azurerm_public_ip" "appgw" {
  for_each            = var.public_ip_configuration != null && var.public_ip_configuration.existing_id == null ? [1] : []
  name                = var.public_ip_configuration.name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}
