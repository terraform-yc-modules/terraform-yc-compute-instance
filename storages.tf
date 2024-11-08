
resource "yandex_compute_disk" "this" {
  name               = var.name
  description = var.description
  folder_id   = local.folder_id
  zone        = var.zone
  size        = var.size
  block_size  = var.block_size
  type        = var.type
  image_id    = var.image_family != null ? data.yandex_compute_image.image[0].id : var.image_id
  snapshot_id = var.snapshot_id
  labels             = var.labels

  dynamic "disk_placement_policy" {
    for_each = var.disk_placement_policy != null ? [var.disk_placement_policy] : []
    content {
      disk_placement_group_id = disk_placement_policy.value.disk_placement_group_id
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