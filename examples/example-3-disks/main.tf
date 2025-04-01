module "dev" {
  source                    = "../../"
  image_family              = "ubuntu-2204-lts"
  zone                      = var.yc_zone
  name                      = "dev"
  hostname                  = "dev"
  description               = "dev"
  memory                    = 4
  gpus                      = 0
  cores                     = 2
  core_fraction             = 100
  serial_port_enable        = true
  allow_stopping_for_update = true
  boot_disk = {
    size       = 93
    block_size = 4096
    type       = "network-ssd"
  }
  enable_oslogin_or_ssh_keys = {
    enable-oslogin = "true"
  }

  network_interfaces = [
    {
      subnet_id = yandex_vpc_subnet.sub_a.id
      ipv4      = true
      nat       = true
    }
  ]
  labels = {
    environment = "development"
    scope       = "dev"
  }
  secondary_disks = [
    {
      auto_delete = true
      device_name = "secondary-disk"
      mode        = "READ_WRITE"
      size        = 100
      block_size  = 4096
      type        = "network-hdd"
    },
    {
      auto_delete = true
      device_name = "third-disk"
      mode        = "READ_WRITE"
      size        = 93
      block_size  = 4096
      type        = "network-ssd-nonreplicated"
      disk_placement_policy = {
        disk_placement_group_id = yandex_compute_disk_placement_group.dev.id
      }
    }
  ]
  filesystems = [
    {
      mode = "READ_WRITE"
      zone = var.yc_zone
    },
    {
      mode = "READ_WRITE"
      zone = var.yc_zone
    }
  ]
}
resource "yandex_compute_disk_placement_group" "dev" {
  name        = "dev-placement-group"
  description = "Placement group for network-ssd-nonreplicated disks"
}
