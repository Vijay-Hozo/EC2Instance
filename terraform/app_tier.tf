# module "app_tier" {
#   source = "./modules/app_tier"

#   name_prefix         = local.name_prefix
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location

#   subnet_id                        = module.network.app_subnet_id
#   gateway_backend_address_pool_ids = module.app_gateway.backend_address_pool_ids

#   admin_username     = var.admin_username
#   ssh_public_key     = var.ssh_public_key
#   vm_sku             = var.app_vm_sku
#   instance_count     = var.app_instance_count
#   min_instance_count = var.app_min_instance_count
#   max_instance_count = var.app_max_instance_count
#   app_port           = var.app_port

#   tags = local.common_tags
# }
module "app_tier" {
  source = "./modules/app_tier"

  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  subnet_id                        = module.network.app_subnet_id
  gateway_backend_address_pool_ids = module.app_gateway.backend_address_pool_ids

  admin_username     = var.admin_username
  ssh_public_key     = var.ssh_public_key
  vm_sku             = var.app_vm_sku
  instance_count     = var.app_instance_count
  min_instance_count = var.app_min_instance_count
  max_instance_count = var.app_max_instance_count
  app_port           = var.app_port

  tags = local.common_tags
}
