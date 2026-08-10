output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.main.name
}

output "gateway_subnet_id" {
  description = "ID of the dedicated Application Gateway subnet."
  value       = azurerm_subnet.gateway.id
}

output "app_subnet_id" {
  description = "ID of the application tier subnet."
  value       = azurerm_subnet.app.id
}

output "data_subnet_id" {
  description = "ID of the delegated data tier subnet."
  value       = azurerm_subnet.data.id
}

output "postgres_private_dns_zone_id" {
  description = "ID of the private DNS zone the PostgreSQL server registers in."
  value       = azurerm_private_dns_zone.postgres.id
}

output "nat_gateway_public_ip" {
  description = "Stable outbound address used by the application tier."
  value       = azurerm_public_ip.nat.ip_address
}
