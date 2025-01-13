terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
resource "azurerm_resource_group" "example" {
  name     = "my-resource-group"
  location = "switzerlandnorth"

}
module "oai" {
  source              = "../.."
  resource_group_name = azurerm_resource_group.example.name
  tags = {
    environment = "example"
  }
  cognitive_accounts = {
    "cognitive-account-switzerlandnorth" = {
      name     = "cognitive-account-switzerlandnorth"
      location = "switzerlandnorth"
      cognitive_deployments = [
        {
          name          = "text-embedding-ada-002-2"
          model_name    = "text-embedding-ada-002"
          model_version = "2"
          sku_capacity  = 350
        },
        {
          name          = "gpt-4-01613"
          model_name    = "gpt-4"
          model_version = "0613"
          sku_capacity  = 20
        }
      ]
    }

  }
}

output "model_version_endpoints" {
  value = module.oai.model_version_endpoints
}

output "cognitive_account_endpoints" {
  value = module.oai.cognitive_account_endpoints
}