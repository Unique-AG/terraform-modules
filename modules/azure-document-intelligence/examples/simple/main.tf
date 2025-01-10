terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
module "document_intelligence" {
  source                = "../.."
  doc_intelligence_name = "my-document-intelligence"
  key_vault_output_settings = {
    key_vault_output_enabled = true
    key_vault_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup1/providers/Microsoft.KeyVault/vaults/vault1"
  }
  accounts = {
    "switzerlandnorth-form-recognizer" = {
      location         = "switzerlandnorth"
      account_kind     = "FormRecognizer"
      account_sku_name = "S0"
    }
  }
  tags = {
    environment = "example"
  }
  resource_group_name = "my-resource-group"
}
