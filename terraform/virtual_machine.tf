/**
 * The VM itself: SSH-key only, managed identity, encrypted managed disk.
 */

resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size

  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  network_interface_ids = [azurerm_network_interface.main.id]

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = "latest"
  }

  os_disk {
    name                 = "osdisk-${local.name_prefix}"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  # Lets the VM authenticate to Key Vault, Storage and other Azure services
  # without a stored credential.
  identity {
    type = "SystemAssigned"
  }

  # Managed-disk encryption at rest with platform keys is on by default and
  # cannot be disabled; this adds encryption for the temp disk and caches.
  encryption_at_host_enabled = var.encryption_at_host_enabled

  boot_diagnostics {}

  custom_data = base64encode(var.custom_data)

  tags = local.common_tags

  lifecycle {
    # Azure rewrites this to the resolved image version, which would otherwise
    # show as drift on every plan.
    ignore_changes = [source_image_reference]
  }
}

# ── Optional data disk ───────────────────────────────────────────────────────

resource "azurerm_managed_disk" "data" {
  count = var.data_disk_size_gb > 0 ? 1 : 0

  name                 = "datadisk-${local.name_prefix}"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  storage_account_type = var.data_disk_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb

  tags = local.common_tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count = var.data_disk_size_gb > 0 ? 1 : 0

  managed_disk_id    = azurerm_managed_disk.data[0].id
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  lun                = 0
  caching            = "ReadWrite"
}
