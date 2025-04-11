data "azurerm_public_ip" "appgw" {
  count               = var.public_ip_resource_group_name != "" && var.public_ip_name != "" ? 1 : 0
  name                = var.public_ip_name
  resource_group_name = var.public_ip_resource_group_name
}
