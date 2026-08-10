/**
 * Data sources and locals only. Resources live in resource_group.tf,
 * networking.tf and virtual_machine.tf.
 */

data "azurerm_client_config" "current" {}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Template    = "azure-vm"
    },
    var.tags,
  )
}
