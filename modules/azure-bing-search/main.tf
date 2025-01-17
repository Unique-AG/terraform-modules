# https://stackoverflow.com/questions/75904744/unable-to-create-bing-services-through-terraform-az-cli
resource "azurerm_resource_group_template_deployment" "argtd_bing_search_v7" {
  name                = var.name
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "name" = {
      value = var.name
    },
    "location" = {
      value = "Global"
    },
    "sku" = {
      value = var.bing_search_v7_sku_name
    },
    "kind" = {
      value = "Bing.Search.v7"
    }
  })
  template_content = file("${path.module}/bing-resource-template.json")
}
