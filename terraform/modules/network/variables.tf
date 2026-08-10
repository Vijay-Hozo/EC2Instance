variable "name_prefix" {
  description = "Prefix applied to every resource name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the network in."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
}

variable "gateway_subnet_prefix" {
  description = "Prefix for the dedicated Application Gateway subnet."
  type        = string
}

variable "app_subnet_prefix" {
  description = "Prefix for the application tier subnet."
  type        = string
}

variable "data_subnet_prefix" {
  description = "Prefix for the delegated data tier subnet."
  type        = string
}

variable "app_port" {
  description = "Port the application listens on, allowed inbound from the gateway subnet."
  type        = number
  default     = 80
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
