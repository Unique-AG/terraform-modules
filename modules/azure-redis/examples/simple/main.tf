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
  public_network_access_enabled = true
  tags = {
    environment = "example"
  }
}
