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


output "boot_disk_id" {
  description = "The ID of the boot disk"
  value       = yandex_compute_disk.this.id
}

output "secondary_disk_ids" {
  description = "The list of secondary disk IDs"
  value       = [for disk_id, disk in yandex_compute_disk.secondary : disk.id]
}

output "filesystem_ids" {
  description = "The list of filesystem IDs"
  value       = [for fs_id, fs in yandex_compute_filesystem.this : fs.id]
}
