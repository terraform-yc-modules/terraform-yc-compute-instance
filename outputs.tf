output "fqdn" {
  description = "The fully qualified DNS name of this instance"
  value       = yandex_compute_instance.this[*].fqdn
}

output "internal_ip" {
  description = "The internal IP address of the instance"
  value       = yandex_compute_instance.this[*].network_interface[0].ip_address
}

output "external_ip" {
  description = "The external IP address of the instance"
  value       = yandex_compute_instance.this[*].network_interface[0].nat_ip_address
}

output "instance_id" {
  description = "The ID of the instance"
  value       = yandex_compute_instance.this[*].id
}

output "instance_id_scalar" {
  description = "The ID of the instance as a scalar value."
  value       = yandex_compute_instance.this.id
}

output "boot_disk_id" {
  description = "The ID of the boot disk"
  value       = var.boot_disk.disk_id != null ? var.boot_disk.disk_id : yandex_compute_disk.this[0].id
}

output "secondary_disk_ids" {
  description = "The list of secondary disk IDs"
  value       = [for disk in yandex_compute_instance.this.secondary_disk : disk.disk_id]
}

output "filesystem_ids" {
  description = "The list of filesystem IDs"
  value       = [for filesystem in yandex_compute_instance.this.filesystem : filesystem.filesystem_id]
}

output "network_interfaces" {
  description = "Full network interface objects attached to the instance."
  value       = yandex_compute_instance.this.network_interface
}

output "attached_boot_disk" {
  description = "Full boot disk attachment object."
  value       = yandex_compute_instance.this.boot_disk[0]
}

output "attached_secondary_disks" {
  description = "Full secondary disk attachment objects."
  value       = yandex_compute_instance.this.secondary_disk
}

output "attached_filesystems" {
  description = "Full filesystem attachment objects."
  value       = yandex_compute_instance.this.filesystem
}
