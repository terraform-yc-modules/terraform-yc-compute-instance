

variable "yc_zone" {
  type        = string
  description = "Yandex Cloud compute default zone"
  default     = "ru-central1-a"
}
variable "ssh_user" {
  description = "User for SSH access"
  type        = string
  default     = "arman"
}

variable "size" {
  description = "The size of the disk in GB."
  type        = number
  default     = 30
}