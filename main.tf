module "example-rg" {
  source = "./resourceGroup"
}

module "example-vn" {
  source = "./virtualNetwork"
  location = "koreacentral"
  resource_group_name = module.example-rg.name
}

