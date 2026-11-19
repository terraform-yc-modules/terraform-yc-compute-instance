output "instance_id" {
  description = "Fixture instance ID."
  value       = module.this.instance_id_scalar
}

output "attached_secondary_disks" {
  description = "Full secondary disk attachment objects for ownership verification."
  value       = module.this.attached_secondary_disks
}

output "attached_filesystems" {
  description = "Full filesystem attachment objects for ownership verification."
  value       = module.this.attached_filesystems
}
