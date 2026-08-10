variable "name_prefix" {
  description = "Prefix applied to every resource name."
  type        = string
}

variable "name_suffix" {
  description = "Short random suffix, needed because Key Vault and PostgreSQL server names are globally unique."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the database in."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant the Key Vault belongs to."
  type        = string
}

variable "key_vault_admin_object_id" {
  description = "Object ID granted Key Vault Secrets Officer, so the apply can write the generated password."
  type        = string
}

variable "delegated_subnet_id" {
  description = "Delegated subnet to inject the server into."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone the server registers its FQDN in."
  type        = string
}

variable "postgres_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
}

variable "sku_name" {
  description = "Compute SKU."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "Storage in MB."
  type        = number
  default     = 32768
}

variable "admin_username" {
  description = "Server admin login."
  type        = string
  default     = "pgadmin"
}

variable "database_name" {
  description = "Name of the initial database."
  type        = string
  default     = "appdb"
}

variable "backup_retention_days" {
  description = "Days of automated backups to retain (7-35)."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "backup_retention_days must be between 7 and 35."
  }
}

variable "geo_redundant_backup_enabled" {
  description = "Replicate backups to the paired region."
  type        = bool
  default     = false
}

variable "high_availability" {
  description = "Enable zone-redundant high availability. Requires a General Purpose or Memory Optimized SKU."
  type        = bool
  default     = false
}

variable "purge_protection_enabled" {
  description = "Block permanent deletion of Key Vault secrets. Enable for production; it cannot be turned off again."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
