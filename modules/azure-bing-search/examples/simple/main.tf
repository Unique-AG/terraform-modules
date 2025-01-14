terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
module "document_intelligence" {
  source              = "../.."
  resource_group_name = "my-resource-group"
  name                = "my-bing-search"
  key_vault_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup1/providers/Microsoft.KeyVault/vaults/vault1"
}
