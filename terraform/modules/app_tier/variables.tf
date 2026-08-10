variable "name_prefix" {
  description = "Prefix applied to every resource name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the scale set in."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "subnet_id" {
  description = "Private subnet to place instances in."
  type        = string
}

variable "gateway_backend_address_pool_ids" {
  description = "Application Gateway backend pool IDs to register instances with."
  type        = list(string)
}

variable "admin_username" {
  description = "Admin username on each instance."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for the admin user. Password authentication is disabled."
  type        = string
}

variable "vm_sku" {
  description = "VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "instance_count" {
  description = "Instances to run under normal load."
  type        = number
  default     = 2
}

variable "min_instance_count" {
  description = "Minimum instances the autoscale rule scales down to."
  type        = number
  default     = 2
}

variable "max_instance_count" {
  description = "Maximum instances the autoscale rule scales up to."
  type        = number
  default     = 4
}

variable "app_port" {
  description = "Port the application listens on."
  type        = number
  default     = 80
}

variable "custom_data" {
  description = "cloud-init script run on first boot. Replace with your own application bootstrap."
  type        = string
  default     = <<-EOT
    #cloud-config
    package_update: true
    packages:
      - nginx
    write_files:
      - path: /var/www/html/index.html
        content: |
          <h1>Application tier</h1>
    runcmd:
      - systemctl enable --now nginx
  EOT
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
