/**
 * Application tier: a Linux virtual machine scale set in the private app subnet,
 * registered with the Application Gateway backend pool. No public IPs.
 */

resource "azurerm_linux_virtual_machine_scale_set" "app" {
  name                = "vmss-${var.name_prefix}-app"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku       = var.vm_sku
  instances = var.instance_count

  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  network_interface {
    name    = "nic-app"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id

      # This is what puts the instances behind the gateway. No public IP block,
      # so instances are only reachable through it.
      application_gateway_backend_address_pool_ids = var.gateway_backend_address_pool_ids
    }
  }

  # A system-assigned identity lets the app authenticate to Key Vault, Storage
  # and other Azure services without a stored credential.
  identity {
    type = "SystemAssigned"
  }

  boot_diagnostics {}

  # Instances are replaced on the operator's schedule. Switch to "Rolling" once
  # you have an Application Health extension reporting readiness.
  upgrade_mode = "Manual"

  custom_data = base64encode(var.custom_data)

  tags = var.tags
}

resource "azurerm_monitor_autoscale_setting" "app" {
  name                = "autoscale-${var.name_prefix}-app"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.app.id

  profile {
    name = "cpu-based"

    capacity {
      default = var.instance_count
      minimum = var.min_instance_count
      maximum = var.max_instance_count
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }
  }

  tags = var.tags
}
