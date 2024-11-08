output "fqdn" {
  description = "The fully qualified DNS name of this instance"
  value       = yandex_compute_instance.this.*.fqdn
}

output "internal_ip" {
  description = "The internal IP address of the instance"
  value       = yandex_compute_instance.this.*.network_interface.0.ip_address
}

output "external_ip" {
  description = "The external IP address of the instance"
  value       = yandex_compute_instance.this.*.network_interface.0.nat_ip_address
}

output "instance_id" {
  description = "The ID of the instance"
  value       = yandex_compute_instance.this.*.id
}

output "disks_ids" {
  description = "The list of attached disk IDs"
  value       = var.secondary_disks != null && length(var.secondary_disks) > 0 ? [for disk in var.secondary_disks : disk.disk_id] : []
}