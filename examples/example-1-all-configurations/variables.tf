

variable "yc_zone" {
  description = "Yandex Cloud compute default zone"
  default     = "ru-central1-a"
  type        = string
}

variable "name_prefix" {
  description = "Optional prefix for disposable resource names. Include a separator when needed; null preserves the documented names."
  type        = string
  default     = null
}
