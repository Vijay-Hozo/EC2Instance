output "scale_set_id" {
  description = "ID of the virtual machine scale set."
  value       = azurerm_linux_virtual_machine_scale_set.app.id
}

output "scale_set_name" {
  description = "Name of the virtual machine scale set."
  value       = azurerm_linux_virtual_machine_scale_set.app.name
}

output "identity_principal_id" {
  description = "Principal ID of the scale set's system-assigned identity — grant it access to Key Vault, Storage, etc."
  value       = azurerm_linux_virtual_machine_scale_set.app.identity[0].principal_id
}
