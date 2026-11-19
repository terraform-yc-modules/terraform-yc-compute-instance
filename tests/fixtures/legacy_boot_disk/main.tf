resource "yandex_compute_disk" "this" {
  name        = "legacy-boot-disk"
  folder_id   = "test-folder"
  zone        = "ru-central1-a"
  size        = 30
  block_size  = 4096
  type        = "network-ssd"
  description = "legacy state fixture"
  labels      = {}
}

output "boot_disk_id" {
  value = yandex_compute_disk.this.id
}
