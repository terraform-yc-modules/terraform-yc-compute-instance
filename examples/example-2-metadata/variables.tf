variable "yc_zone" {
  description = "Yandex Cloud compute default zone"
  default     = "ru-central1-a"
  type        = string
}

variable "cores" {
  description = "CPU cores for the metadata example. Override for a minimum-resource smoke test."
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in GiB for the metadata example. Override for a minimum-resource smoke test."
  type        = number
  default     = 4
}

variable "boot_disk_size" {
  description = "Boot disk size in GiB for the metadata example. Override only to a size supported by the selected image."
  type        = number
  default     = 30
}

variable "name_prefix" {
  description = "Optional prefix for disposable resource names. Include a separator when needed; null preserves the documented names."
  type        = string
  default     = null
}

variable "ssh_public_key" {
  description = "Optional SSH public-key content for generated cloud-config. Null uses OS Login so the example contains no authorized key."
  type        = string
  default     = null
  nullable    = true
}

variable "user_data" {
  description = "Optional raw cloud-init user-data. When set, it replaces generated SSH and agent configuration."
  type        = string
  default     = null
  nullable    = true
}
