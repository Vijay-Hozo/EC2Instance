# ── Subscription & naming ────────────────────────────────────────────────────

variable "subscription_id" {
  description = "Azure subscription to deploy into. Also settable via ARM_SUBSCRIPTION_ID."
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant. Also settable via ARM_TENANT_ID."
  type        = string
}

variable "project_name" {
  description = "Short project name used to prefix every resource."
  type        = string
  default     = "synfra-app"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,11}$", var.project_name))
    error_message = "project_name must be 2-12 characters of lowercase letters, digits or hyphens, and start with a letter or digit."
  }
}

variable "environment" {
  description = "Deployment environment. Also used in resource names."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, staging, prod."
  }
}

variable "location" {
  description = "Azure region to deploy into."
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Extra tags merged onto every resource."
  type        = map(string)
  default     = {}
}

# ── Network tier ─────────────────────────────────────────────────────────────

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "gateway_subnet_prefix" {
  description = "Prefix for the Application Gateway subnet. Must be dedicated to the gateway."
  type        = string
  default     = "10.0.0.0/24"
}

variable "app_subnet_prefix" {
  description = "Prefix for the application tier subnet."
  type        = string
  default     = "10.0.10.0/24"
}

variable "data_subnet_prefix" {
  description = "Prefix for the data tier subnet. Delegated to PostgreSQL Flexible Server, so it cannot host anything else."
  type        = string
  default     = "10.0.20.0/24"
}

# ── Application Gateway (web tier) ───────────────────────────────────────────

variable "gateway_sku_name" {
  description = "Application Gateway SKU name."
  type        = string
  default     = "Standard_v2"
}

variable "gateway_capacity" {
  description = "Application Gateway instance count. Ignored when autoscaling is configured."
  type        = number
  default     = 2
}

variable "health_check_path" {
  description = "HTTP path the gateway probe requests."
  type        = string
  default     = "/"
}

# ── Application tier ─────────────────────────────────────────────────────────

variable "app_port" {
  description = "Port the application listens on behind the gateway."
  type        = number
  default     = 80
}

variable "admin_username" {
  description = "Admin username on the application VMs."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for the VM admin user, e.g. contents of ~/.ssh/id_rsa.pub. Required — password auth is disabled."
  type        = string
}

variable "app_vm_sku" {
  description = "VM size for the application tier."
  type        = string
  default     = "Standard_B2s"
}

variable "app_instance_count" {
  description = "Application instances to run under normal load."
  type        = number
  default     = 2
}

variable "app_min_instance_count" {
  description = "Minimum instances the autoscale rule will scale down to."
  type        = number
  default     = 2
}

variable "app_max_instance_count" {
  description = "Maximum instances the autoscale rule will scale up to."
  type        = number
  default     = 4
}

# ── Data tier ────────────────────────────────────────────────────────────────

variable "postgres_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
}

variable "postgres_sku_name" {
  description = "Flexible Server compute SKU."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  description = "Storage in MB. Must be one of the sizes the service supports (32768, 65536, 131072, ...)."
  type        = number
  default     = 32768
}

variable "postgres_admin_username" {
  description = "Server admin login. The password is generated and stored in Key Vault."
  type        = string
  default     = "pgadmin"
}

variable "postgres_database_name" {
  description = "Name of the initial database."
  type        = string
  default     = "appdb"
}

variable "postgres_backup_retention_days" {
  description = "Days of automated backups to retain (7-35)."
  type        = number
  default     = 7
}

variable "postgres_high_availability" {
  description = "Enable zone-redundant high availability. Not supported on Burstable SKUs — pair with a General Purpose postgres_sku_name."
  type        = bool
  default     = false
}
