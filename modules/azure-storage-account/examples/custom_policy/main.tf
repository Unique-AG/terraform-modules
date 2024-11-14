terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
module "sa" {
  source              = "../.."
  name                = "my-storage-account"
  resource_group_name = "my-resource-group"
  location            = "switzerlandnorth"
  tags = {
    environment = "example"
  }
}
