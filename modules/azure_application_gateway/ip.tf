resource "azurerm_public_ip" "appgw" {
  count               = var.public_ip_address_id == "" ? 1 : 0
  name                = var.ip_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}
