output "server_id" {
  description = "ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.main.id
}

output "fqdn" {
  description = "Private FQDN of the server. Resolvable only from inside the virtual network."
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "database_name" {
  description = "Name of the initial database."
  value       = azurerm_postgresql_flexible_server_database.app.name
}

output "admin_username" {
  description = "Server admin login."
  value       = azurerm_postgresql_flexible_server.main.administrator_login
}

output "key_vault_name" {
  description = "Name of the Key Vault holding the admin password."
  value       = azurerm_key_vault.main.name
}

output "key_vault_id" {
  description = "ID of the Key Vault, for granting the application's identity read access."
  value       = azurerm_key_vault.main.id
}

output "password_secret_id" {
  description = "Key Vault secret ID holding the generated admin password."
  value       = azurerm_key_vault_secret.postgres_password.id
}
