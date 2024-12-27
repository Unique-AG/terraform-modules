terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
module "oai" {
  source              = "../.."
  resource_group_name = "my-resource-group"
  tags = {
    environment = "example"
  }
  cognitive_accounts = {
    "cognitive-account-switzerlandnorth" = {
      name     = "cognitive-account-switzerlandnorth"
      location = "switzerlandnorth"
    }
  }
  cognitive_deployments = {
    "text-embedding-ada-002-switzerlandnorth" = {
      name              = "text-embedding-ada-002"
      model_name        = "text-embedding-ada-002"
      model_version     = "2"
      sku_capacity      = 350
      location          = "switzerlandnorth"
      cognitive_account = "cognitive-account-switzerlandnorth"
    },
    "gpt-4-switzerlandnorth" = {
      name              = "gpt-4"
      model_name        = "gpt-4"
      model_version     = "0613"
      sku_capacity      = 20
      location          = "switzerlandnorth"
      cognitive_account = "cognitive-account-switzerlandnorth"
    }
  }
}

output "model_version_endpoints" {
  value       = module.oai.model_version_endpoints
}
