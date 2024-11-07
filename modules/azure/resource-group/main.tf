resource "azurerm_resource_group" "this" {
  for_each   = var.resource_groups
  name       = each.value
  location   = each.value.location
  managed_by = try(each.value.managed_by, null)
  tags       = try(each.value.tags, null)
}
