/**
 * Data sources and locals only. Every resource is created through a module call
 * in its own file: network.tf, app_gateway.tf, app_tier.tf, database.tf.
 */

data "azurerm_client_config" "current" {}

# Key Vault names are globally unique, so derive a short stable suffix rather
# than asking the user to invent one.
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Template    = "azure-3-tier-app"
    },
    var.tags,
  )
}
