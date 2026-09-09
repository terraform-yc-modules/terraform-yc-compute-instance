variable "yc_zone" {
  description = "Yandex Cloud compute zone."
  type        = string
  default     = "ru-central1-a"
}

variable "name_prefix" {
  description = "Prefix for disposable resource names. Include a separator when needed."
  type        = string
  default     = "external-storage-"
}

variable "boot_disk_size" {
  description = "Fixture boot disk size in GiB. The selected image determines the supported minimum."
  type        = number
  default     = 30
}

variable "cores" {
  description = "CPU cores for the fixture instance."
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in GiB for the fixture instance."
  type        = number
  default     = 4
}

variable "external_secondary_disk_size" {
  description = "Fixture-owned external secondary disk size in GiB."
  type        = number
  default     = 20
}

variable "external_filesystem_size" {
  description = "Fixture-owned external filesystem size in GiB."
  type        = number
  default     = 20
}

variable "secondary_disk_size" {
  description = "Module-created secondary disk size in GiB."
  type        = number
  default     = 20
}

variable "filesystem_size" {
  description = "Module-created filesystem size in GiB."
  type        = number
  default     = 20
}
