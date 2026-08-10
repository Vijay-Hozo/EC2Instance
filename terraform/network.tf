module "network" {
  source = "./modules/network"

  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  vnet_address_space    = var.vnet_address_space
  gateway_subnet_prefix = var.gateway_subnet_prefix
  app_subnet_prefix     = var.app_subnet_prefix
  data_subnet_prefix    = var.data_subnet_prefix
  app_port              = var.app_port

  tags = local.common_tags
}
