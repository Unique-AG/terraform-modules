resource "azurerm_redis_cache" "arc" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  capacity                      = var.capacity
  family                        = var.family
  sku_name                      = var.sku_name
  minimum_tls_version           = var.min_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
}