terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
module "redis" {
  source              = "../.."
  name                = "my-redis"
  resource_group_name = "my-resource-group"
  location            = "switzerlandnorth"
  tags = {
    environment = "example"
  }
}
