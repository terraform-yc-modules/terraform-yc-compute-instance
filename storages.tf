resource "yandex_compute_disk" "this" {
  count          = var.boot_disk.disk_id == null ? 1 : 0
  name           = var.name
  description    = var.description
  folder_id      = local.folder_id
  zone           = var.zone
  size           = lookup(var.boot_disk, "size", null)
  block_size     = lookup(var.boot_disk, "block_size", null)
  type           = lookup(var.boot_disk, "type", null)
  image_id       = var.boot_disk.image_id != null ? var.boot_disk.image_id : (var.boot_disk.snapshot_id == null && var.image_family != null ? data.yandex_compute_image.image[0].id : null)
  snapshot_id    = lookup(var.boot_disk, "snapshot_id", null)
  labels         = var.labels != null ? var.labels : null
  kms_key_id     = lookup(var.boot_disk, "kms_key_id", null)
  dynamic "disk_placement_policy" {
    for_each = lookup(var.boot_disk, "type", null) == "network-ssd-nonreplicated" && var.disk_placement_group_id != null ? [var.disk_placement_group_id] : []
    content {
      disk_placement_group_id = disk_placement_policy.value
    }
  }
}

resource "yandex_compute_disk" "secondary" {
  for_each       = { for idx, disk in var.secondary_disks : idx => disk if disk.disk_id == null }
  name           = format("%s-secondary-disk-%d", var.name, each.key + 1)
  description    = lookup(each.value, "description", null)
  folder_id      = local.folder_id
  zone           = var.zone
  size           = lookup(each.value, "size", null)
  block_size     = lookup(each.value, "block_size", null)
  type           = lookup(each.value, "type", null)
  labels         = var.labels != null ? var.labels : null
  kms_key_id     = lookup(each.value, "kms_key_id", null)
  dynamic "disk_placement_policy" {
    for_each = lookup(each.value, "type", null) == "network-ssd-nonreplicated" && var.disk_placement_group_id != null ? [var.disk_placement_group_id] : []
    content {
      disk_placement_group_id = var.disk_placement_group_id
    }
  }
}


resource "yandex_compute_filesystem" "this" {
  for_each    = { for idx, filesystem in var.filesystems : idx => filesystem if filesystem.filesystem_id == null }
  name        = format("%s-filesystem-%d", var.name, each.key + 1)
  description = lookup(each.value, "description", null)
  folder_id   = local.folder_id
  zone        = lookup(each.value, "zone", null)
  size        = lookup(each.value, "size", null)
  block_size  = lookup(each.value, "block_size", null)
  type        = lookup(each.value, "type", null)
  labels      = var.labels != null ? var.labels : null
}
