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

# ── Network ──────────────────────────────────────────────────────────────────

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  description = "Prefix for the VM's subnet. Must sit inside vnet_address_space."
  type        = string
  default     = "10.0.1.0/24"
}

variable "assign_public_ip" {
  description = "Give the VM a public IP. When false, a NAT gateway provides outbound access instead — Azure is retiring default outbound access, so a VM with neither has no egress at all."
  type        = bool
  default     = true
}

variable "app_port" {
  description = "Port the VM serves traffic on."
  type        = number
  default     = 80
}

variable "ingress_cidr" {
  description = "CIDR allowed to reach app_port. Narrow this — the default is the whole internet."
  type        = string
  default     = "0.0.0.0/0"
}

variable "allow_ssh" {
  description = "Open port 22. Leave false and use Azure Bastion or the serial console instead."
  type        = bool
  default     = false
}

variable "ssh_source_cidr" {
  description = "CIDR allowed to reach port 22. Only used when allow_ssh is true. Never set this to 0.0.0.0/0."
  type        = string
  default     = "10.0.0.0/8"
}

# ── Virtual machine ──────────────────────────────────────────────────────────

variable "vm_size" {
  description = "VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username. Azure rejects reserved names like 'admin' and 'root'."
  type        = string
  default     = "azureuser"

  validation {
    condition     = !contains(["admin", "administrator", "root", "test", "user", "guest"], lower(var.admin_username))
    error_message = "admin_username cannot be a reserved Azure username (admin, administrator, root, test, user, guest)."
  }
}

variable "ssh_public_key" {
  description = "SSH public key for the admin user, e.g. contents of ~/.ssh/id_rsa.pub. Required — password auth is disabled."
  type        = string
}

variable "image_publisher" {
  description = "Marketplace image publisher."
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Marketplace image offer."
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "Marketplace image SKU."
  type        = string
  default     = "22_04-lts-gen2"
}

variable "os_disk_type" {
  description = "OS disk storage type."
  type        = string
  default     = "StandardSSD_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.os_disk_type)
    error_message = "os_disk_type must be Standard_LRS, StandardSSD_LRS or Premium_LRS."
  }
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB. Must be at least as large as the image."
  type        = number
  default     = 30
}

variable "encryption_at_host_enabled" {
  description = "Encrypt the temp disk and VM caches as well as the managed disks. Not supported on every VM size."
  type        = bool
  default     = false
}

variable "data_disk_size_gb" {
  description = "Size of an attached data disk in GB. Zero creates no data disk."
  type        = number
  default     = 0
}

variable "data_disk_type" {
  description = "Data disk storage type."
  type        = string
  default     = "StandardSSD_LRS"
}

variable "custom_data" {
  description = "cloud-init script run on first boot. Replace with your own bootstrap."
  type        = string
  default     = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - nginx
    write_files:
      - path: /var/www/html/index.html
        content: |
          <h1>Hello from Azure</h1>
    runcmd:
      - systemctl enable --now nginx
  EOT
}
