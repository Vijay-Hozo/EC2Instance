/**
 * A virtual network with one subnet, an NSG, and optionally a public IP.
 */

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = var.vnet_address_space

  tags = local.common_tags
}

resource "azurerm_subnet" "main" {
  name                 = "snet-${local.name_prefix}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_prefix]
}

# ── Network security ─────────────────────────────────────────────────────────

resource "azurerm_network_security_group" "main" {
  name                = "nsg-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # Inbound on the application port from the allowed range.
  security_rule {
    name                       = "AllowAppPortInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.app_port)
    source_address_prefix      = var.ingress_cidr
    destination_address_prefix = "*"
  }

  # No SSH rule. Shell access goes through Azure Bastion or the serial console,
  # so port 22 is never exposed. Set allow_ssh = true only if you accept that.
  dynamic "security_rule" {
    for_each = var.allow_ssh ? [1] : []

    content {
      name                       = "AllowSshInbound"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = var.ssh_source_cidr
      destination_address_prefix = "*"
    }
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# ── Addressing ───────────────────────────────────────────────────────────────

resource "azurerm_public_ip" "main" {
  count = var.assign_public_ip ? 1 : 0

  name                = "pip-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.common_tags
}

# A NAT gateway gives outbound access without a public IP on the VM. Azure is
# retiring default outbound access, so a VM with neither will have no egress.
resource "azurerm_public_ip" "nat" {
  count = var.assign_public_ip ? 0 : 1

  name                = "pip-${local.name_prefix}-nat"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.common_tags
}

resource "azurerm_nat_gateway" "main" {
  count = var.assign_public_ip ? 0 : 1

  name                = "nat-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku_name            = "Standard"

  tags = local.common_tags
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  count = var.assign_public_ip ? 0 : 1

  nat_gateway_id       = azurerm_nat_gateway.main[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

resource "azurerm_subnet_nat_gateway_association" "main" {
  count = var.assign_public_ip ? 0 : 1

  subnet_id      = azurerm_subnet.main.id
  nat_gateway_id = azurerm_nat_gateway.main[0].id
}

resource "azurerm_network_interface" "main" {
  name                = "nic-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.assign_public_ip ? azurerm_public_ip.main[0].id : null
  }

  tags = local.common_tags
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}
