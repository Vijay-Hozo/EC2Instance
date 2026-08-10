/**
 * Network tier: a virtual network with three subnets — gateway (Application
 * Gateway, dedicated), app (private, NAT egress) and data (delegated to
 * PostgreSQL Flexible Server), plus the private DNS zone the database needs.
 */

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space

  tags = var.tags
}

# ── Subnets ──────────────────────────────────────────────────────────────────

# Application Gateway requires a dedicated subnet and rejects a restrictive NSG,
# so this one deliberately has none attached.
resource "azurerm_subnet" "gateway" {
  name                 = "snet-gateway"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.gateway_subnet_prefix]
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.app_subnet_prefix]
}

# Flexible Server injects itself into a delegated subnet, which then cannot hold
# any other resource type.
resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.data_subnet_prefix]

  delegation {
    name = "postgres-flexible-server"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# ── Network security ─────────────────────────────────────────────────────────

resource "azurerm_network_security_group" "app" {
  name                = "nsg-${var.name_prefix}-app"
  resource_group_name = var.resource_group_name
  location            = var.location

  # Inbound from the gateway subnet only — nothing from the internet.
  security_rule {
    name                       = "AllowGatewayInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.app_port)
    source_address_prefix      = var.gateway_subnet_prefix
    destination_address_prefix = "*"
  }

  # Application Gateway v2 health probes and management traffic arrive on these
  # ports from the platform, not from the gateway subnet address range.
  security_rule {
    name                       = "AllowGatewayManager"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
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

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

# ── Outbound egress for the application tier ─────────────────────────────────

resource "azurerm_public_ip" "nat" {
  name                = "pip-${var.name_prefix}-nat"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# A NAT gateway gives the app tier a stable, predictable outbound address —
# preferable to default outbound access, which Azure is retiring.
resource "azurerm_nat_gateway" "main" {
  name                = "nat-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "Standard"

  tags = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "app" {
  subnet_id      = azurerm_subnet.app.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

# ── Private DNS for the database ─────────────────────────────────────────────

resource "azurerm_private_dns_zone" "postgres" {
  name                = "${var.name_prefix}.private.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "link-${var.name_prefix}-postgres"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false

  tags = var.tags
}
