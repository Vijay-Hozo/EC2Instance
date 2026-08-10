module "database" {
  source = "./modules/database"

  name_prefix               = local.name_prefix
  name_suffix               = random_string.suffix.result
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  key_vault_admin_object_id = data.azurerm_client_config.current.object_id

  delegated_subnet_id = module.network.data_subnet_id
  private_dns_zone_id = module.network.postgres_private_dns_zone_id

  postgres_version      = var.postgres_version
  sku_name              = var.postgres_sku_name
  storage_mb            = var.postgres_storage_mb
  admin_username        = var.postgres_admin_username
  database_name         = var.postgres_database_name
  backup_retention_days = var.postgres_backup_retention_days
  high_availability     = var.postgres_high_availability

  tags = local.common_tags

  # The server can only be created once its subnet delegation and the private
  # DNS zone link exist, and neither is expressible as a direct attribute
  # reference from here.
  depends_on = [module.network]
}
