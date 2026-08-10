/**
 * Data tier: a PostgreSQL Flexible Server injected into the delegated data
 * subnet, so it has no public endpoint at all.
 *
 * Unlike RDS, Azure has no service-managed admin password, so one is generated
 * here and written to a Key Vault secret. It is still present in Terraform
 * state — keep state in a remote backend with restricted access.
 */

resource "random_password" "postgres" {
  length  = 32
  special = true
  # Azure rejects these in the admin password.
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ── Secret storage ───────────────────────────────────────────────────────────

resource "azurerm_key_vault" "main" {
  # Vault names are globally unique and capped at 24 characters, hence the
  # random suffix and the truncated prefix.
  name                = substr("kv-${var.name_prefix}-${var.name_suffix}", 0, 24)
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  # RBAC rather than legacy access policies.
  rbac_authorization_enabled = true

  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = 7

  tags = var.tags
}

# Without this the apply below fails: RBAC-authorized vaults grant no data-plane
# access to the creating principal by default.
resource "azurerm_role_assignment" "key_vault_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.key_vault_admin_object_id
}

resource "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-admin-password"
  value        = random_password.postgres.result
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.key_vault_admin]
}

# ── Server ───────────────────────────────────────────────────────────────────

resource "azurerm_postgresql_flexible_server" "main" {
  name                = "psql-${var.name_prefix}-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  version    = var.postgres_version
  sku_name   = var.sku_name
  storage_mb = var.storage_mb

  administrator_login    = var.admin_username
  administrator_password = random_password.postgres.result

  # Private access: no firewall rules, no public endpoint, resolvable only
  # inside the virtual network.
  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = false

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  # Zone-redundant HA is unavailable on Burstable SKUs, so it is opt-in.
  dynamic "high_availability" {
    for_each = var.high_availability ? [1] : []

    content {
      mode = "ZoneRedundant"
    }
  }

  tags = var.tags

  lifecycle {
    # The zone is chosen by Azure at create time; letting Terraform see drift
    # here would force a replacement on every plan.
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"

  lifecycle {
    prevent_destroy = false
  }
}

# Log statements slower than a second so slow queries are visible in Azure Monitor.
resource "azurerm_postgresql_flexible_server_configuration" "log_min_duration" {
  name      = "log_min_duration_statement"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "1000"
}
