output "id" {
  description = "ID of the Application Gateway."
  value       = azurerm_application_gateway.main.id
}

output "public_ip_address" {
  description = "Public IP address serving the application."
  value       = azurerm_public_ip.gateway.ip_address
}

output "backend_address_pool_ids" {
  description = "Backend pool IDs the application scale set registers with."
  value       = [for pool in azurerm_application_gateway.main.backend_address_pool : pool.id]
}
