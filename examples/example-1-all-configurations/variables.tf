

variable "yc_zone" {
  description = "Yandex Cloud compute default zone"
  default     = "ru-central1-a"
  type        = string
}

variable "cores" {
  description = "CPU cores for the comprehensive example. Override for a minimum-resource smoke test."
  type        = number
  default     = 4
}

variable "memory" {
  description = "Memory in GiB for the comprehensive example. Override for a minimum-resource smoke test."
  type        = number
  default     = 8
}

variable "boot_disk_size" {
  description = "Boot disk size in GiB for the comprehensive example. Override for a minimum-resource smoke test."
  type        = number
  default     = 30
}

variable "secondary_disk_size" {
  description = "Secondary disk size in GiB for the comprehensive example. Override for a minimum-resource smoke test."
  type        = number
  default     = 100
}

variable "name_prefix" {
  description = "Optional prefix for disposable resource names. Include a separator when needed; null preserves the documented names."
  type        = string
  default     = null
}
