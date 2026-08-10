module "app_gateway" {
  source = "./modules/app_gateway"

  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  subnet_id         = module.network.gateway_subnet_id
  app_port          = var.app_port
  health_check_path = var.health_check_path
  sku_name          = var.gateway_sku_name
  capacity          = var.gateway_capacity

  tags = local.common_tags
}
