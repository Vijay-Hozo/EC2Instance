output "resource_group_name" {
  description = "Resource group holding every resource in this stack."
  value       = azurerm_resource_group.main.name
}

output "vm_id" {
  description = "Resource ID of the virtual machine."
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_name" {
  description = "Name of the virtual machine."
  value       = azurerm_linux_virtual_machine.main.name
}

output "private_ip_address" {
  description = "Private IP of the VM."
  value       = azurerm_linux_virtual_machine.main.private_ip_address
}

output "public_ip_address" {
  description = "Public IP of the VM, or null when assign_public_ip is false."
  value       = var.assign_public_ip ? azurerm_public_ip.main[0].ip_address : null
}

output "application_url" {
  description = "URL the VM serves on, when it has a public address."
  value       = var.assign_public_ip ? "http://${azurerm_public_ip.main[0].ip_address}:${var.app_port}" : null
}

output "outbound_ip_address" {
  description = "Address the VM's outbound traffic appears from — its own public IP, or the NAT gateway's."
  value       = var.assign_public_ip ? azurerm_public_ip.main[0].ip_address : azurerm_public_ip.nat[0].ip_address
}

output "identity_principal_id" {
  description = "Principal ID of the VM's system-assigned identity — grant it access to Key Vault, Storage, etc."
  value       = azurerm_linux_virtual_machine.main.identity[0].principal_id
}

output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.main.id
}

output "subnet_id" {
  description = "Resource ID of the subnet."
  value       = azurerm_subnet.main.id
}

output "ssh_command" {
  description = "SSH command, when a public IP and port 22 are both available."
  value = (var.assign_public_ip && var.allow_ssh
    ? "ssh ${var.admin_username}@${azurerm_public_ip.main[0].ip_address}"
    : "SSH is not exposed — use Azure Bastion or `az serial-console connect`."
  )
}
