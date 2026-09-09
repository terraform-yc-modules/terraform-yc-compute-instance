data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_disk" "external_boot" {
  name     = "${var.name_prefix}external-boot"
  zone     = var.yc_zone
  size     = var.boot_disk_size
  image_id = data.yandex_compute_image.ubuntu.id
}

resource "yandex_compute_disk" "external_secondary" {
  name = "${var.name_prefix}external-secondary"
  zone = var.yc_zone
  size = var.external_secondary_disk_size
  type = "network-hdd"
}

resource "yandex_compute_filesystem" "external" {
  name = "${var.name_prefix}external-filesystem"
  zone = var.yc_zone
  size = var.external_filesystem_size
  type = "network-ssd"
}

module "this" {
  source = "../../"

  name        = "${var.name_prefix}instance"
  hostname    = "${var.name_prefix}instance"
  description = "Mixed external and module-created storage fixture"
  zone        = var.yc_zone
  cores       = var.cores
  memory      = var.memory

  boot_disk = {
    disk_id     = yandex_compute_disk.external_boot.id
    auto_delete = false
  }

  secondary_disks = [
    {
      disk_id     = yandex_compute_disk.external_secondary.id
      auto_delete = false
      device_name = "external-secondary"
    },
    {
      size        = var.secondary_disk_size
      type        = "network-hdd"
      device_name = "module-secondary"
    },
  ]

  filesystems = [
    {
      filesystem_id = yandex_compute_filesystem.external.id
      device_name   = "external-filesystem"
    },
    {
      size        = var.filesystem_size
      zone        = var.yc_zone
      device_name = "module-filesystem"
    },
  ]

  enable_oslogin_or_ssh_keys = {
    enable-oslogin = "true"
  }

  user_data = <<-EOT
    #cloud-config
    runcmd:
      - echo module-refactor-marker > /var/tmp/module-refactor-marker
  EOT

  network_interfaces = [{
    subnet_id = yandex_vpc_subnet.this.id
    nat       = true
  }]
}
