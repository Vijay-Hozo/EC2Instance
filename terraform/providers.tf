terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Remote state is environment-specific. Configure it with a partial backend:
  #   terraform init -backend-config=environments/dev.backend.hcl
  # backend "azurerm" {}
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
