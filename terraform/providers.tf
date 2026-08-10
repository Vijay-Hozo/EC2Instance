terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }

  # Remote state is environment-specific. Configure it with a partial backend:
  #   terraform init -backend-config=environments/dev.backend.hcl
  # backend "azurerm" {}
}

provider "azurerm" {
  features {
    key_vault {
      # Soft-deleted vaults block re-creating a vault with the same name, which
      # makes iterating on a dev environment painful.
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
