variable "name_prefix" {
  description = "Prefix applied to every resource name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the gateway in."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "subnet_id" {
  description = "Dedicated subnet for the Application Gateway."
  type        = string
}

variable "app_port" {
  description = "Port the backend application listens on."
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "HTTP path the backend probe requests."
  type        = string
  default     = "/"
}

variable "sku_name" {
  description = "Gateway SKU. Used for both the SKU name and tier, so it must be a v2 SKU."
  type        = string
  default     = "Standard_v2"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_name)
    error_message = "sku_name must be Standard_v2 or WAF_v2 — v1 SKUs are retired."
  }
}

variable "capacity" {
  description = "Fixed instance count for the gateway."
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
