

variable "yc_zone" {
  description = "Yandex Cloud compute default zone"
  default     = "ru-central1-a"
  type        = string
}

variable "cores" {
  description = "CPU cores for the disk example. Override for a minimum-resource smoke test."
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in GiB for the disk example. Override for a minimum-resource smoke test."
  type        = number
  default     = 4
}

variable "boot_disk_size" {
  description = "Boot disk size in GiB for the disk example. Override only to a size supported by the selected image."
  type        = number
  default     = 93
}

variable "secondary_disk_size" {
  description = "Network-HDD secondary disk size in GiB. Override for a minimum-resource smoke test."
  type        = number
  default     = 100
}

variable "nonreplicated_disk_size" {
  description = "network-ssd-nonreplicated disk size in GiB. Keep the service-supported 93 GiB default unless using a compatible preset."
  type        = number
  default     = 93
}

variable "name_prefix" {
  description = "Optional prefix for disposable resource names. Include a separator when needed; null preserves the documented names."
  type        = string
  default     = null
}
