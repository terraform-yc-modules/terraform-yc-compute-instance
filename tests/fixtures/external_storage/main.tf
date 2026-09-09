resource "yandex_compute_disk" "boot" {
  name = "fixture-external-boot"
  zone = "ru-central1-a"
  size = 30
}

resource "yandex_compute_disk" "secondary" {
  name = "fixture-external-secondary"
  zone = "ru-central1-a"
  size = 20
}

resource "yandex_compute_filesystem" "filesystem" {
  name = "fixture-external-filesystem"
  zone = "ru-central1-a"
  size = 10
}

module "this" {
  source = "../../.."

  name      = "external-storage-regression"
  folder_id = "test-folder"
  zone      = "ru-central1-a"

  enable_oslogin_or_ssh_keys = {
    enable-oslogin = "true"
  }

  network_interfaces = [{
    subnet_id = "test-subnet"
    nat       = true
  }]

  boot_disk = {
    disk_id = yandex_compute_disk.boot.id
    create  = false
  }

  secondary_disks = [{
    disk_id = yandex_compute_disk.secondary.id
    create  = false
  }]

  filesystems = [{
    filesystem_id = yandex_compute_filesystem.filesystem.id
    zone          = "ru-central1-a"
    create        = false
  }]
}
