/**
 * Web tier: an internet-facing Application Gateway v2 that terminates HTTP and
 * forwards to the application tier scale set via its backend pool.
 */

resource "azurerm_public_ip" "gateway" {
  name                = "pip-${var.name_prefix}-agw"
  resource_group_name = var.resource_group_name
  location            = var.location

  # Application Gateway v2 requires a Standard, statically allocated address.
  allocation_method = "Static"
  sku               = "Standard"

  tags = var.tags
}

locals {
  # Application Gateway config is a graph of named blocks that reference each
  # other by name, so the names are declared once here.
  frontend_ip_name   = "feip-public"
  frontend_port_name = "feport-http"
  backend_pool_name  = "bepool-app"
  http_setting_name  = "behttp-app"
  listener_name      = "listener-http"
  probe_name         = "probe-app"
}

resource "azurerm_application_gateway" "main" {
  name                = "agw-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.sku_name
    tier     = var.sku_name
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = "gwip"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_name
    public_ip_address_id = azurerm_public_ip.gateway.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  # Members are registered by the scale set, not listed here — leaving the pool
  # empty is intentional.
  backend_address_pool {
    name = local.backend_pool_name
  }

  probe {
    name                                      = local.probe_name
    protocol                                  = "Http"
    path                                      = var.health_check_path
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true

    match {
      status_code = ["200-399"]
    }
  }

  backend_http_settings {
    name                                = local.http_setting_name
    cookie_based_affinity               = "Disabled"
    port                                = var.app_port
    protocol                            = "Http"
    request_timeout                     = 30
    probe_name                          = local.probe_name
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule-http"
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  tags = var.tags
}
