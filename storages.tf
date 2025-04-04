resource "yandex_compute_disk" "this" {
  name        = var.name
  description = var.description
  folder_id   = local.folder_id
  zone        = var.zone
  size        = lookup(var.boot_disk, "size", null)
  block_size  = lookup(var.boot_disk, "block_size", null)
  type        = lookup(var.boot_disk, "type", null)
  image_id    = lookup(var.boot_disk, "image_id", null) != null ? lookup(var.boot_disk, "image_id", null) : (var.image_family != null ? data.yandex_compute_image.image[0].id : null)
  snapshot_id = lookup(var.boot_disk, "snapshot_id", null)
  labels      = var.labels != null ? var.labels : null

  dynamic "disk_placement_policy" {
    for_each = lookup(var.boot_disk, "type", null) == "network-ssd-nonreplicated" && var.disk_placement_group_id != null ? [var.disk_placement_group_id] : []
    content {
      disk_placement_group_id = disk_placement_policy.value
    }
  }
}

resource "yandex_compute_disk" "secondary" {
  for_each    = var.secondary_disks != null ? { for idx, s in var.secondary_disks : idx => s } : {}
  name        = format("%s-secondary-disk-%d", var.name, each.key + 1)
  description = lookup(each.value, "description", null)
  folder_id   = local.folder_id
  zone        = var.zone
  size        = lookup(each.value, "size", null)
  block_size  = lookup(each.value, "block_size", null)
  type        = lookup(each.value, "type", null)
  labels      = var.labels != null ? var.labels : null
  dynamic "disk_placement_policy" {
    for_each = lookup(each.value, "type", null) == "network-ssd-nonreplicated" && var.disk_placement_group_id != null ? [var.disk_placement_group_id] : []
    content {
      disk_placement_group_id = var.disk_placement_group_id
    }
  }
}


resource "yandex_compute_filesystem" "this" {
  for_each    = var.filesystems != null ? { for idx, fs in var.filesystems : idx => fs } : {}
  name        = format("%s-filesystem-%d", var.name, each.key + 1)
  description = lookup(each.value, "description", null)
  folder_id   = local.folder_id
  zone        = lookup(each.value, "zone", null)
  size        = lookup(each.value, "size", null)
  block_size  = lookup(each.value, "block_size", null)
  type        = lookup(each.value, "type", null)
  labels      = var.labels != null ? var.labels : null
}
