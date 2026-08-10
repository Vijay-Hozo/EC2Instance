output "application_url" {
  description = "Public URL of the application, served by the Application Gateway."
  value       = "http://${module.app_gateway.public_ip_address}"
}

output "gateway_public_ip" {
  description = "Public IP address of the Application Gateway."
  value       = module.app_gateway.public_ip_address
}

output "resource_group_name" {
  description = "Resource group holding every resource in this stack."
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "ID of the virtual network."
  value       = module.network.vnet_id
}

output "app_subnet_id" {
  description = "ID of the application tier subnet."
  value       = module.network.app_subnet_id
}

output "scale_set_id" {
  description = "ID of the application tier virtual machine scale set."
  value       = module.app_tier.scale_set_id
}

output "postgres_fqdn" {
  description = "Private FQDN of the PostgreSQL server. Resolvable only from inside the virtual network."
  value       = module.database.fqdn
}

output "postgres_database_name" {
  description = "Name of the initial database."
  value       = module.database.database_name
}

output "postgres_password_secret_id" {
  description = "Key Vault secret ID holding the PostgreSQL admin password."
  value       = module.database.password_secret_id
}

output "key_vault_name" {
  description = "Name of the Key Vault holding the database credentials."
  value       = module.database.key_vault_name
}
