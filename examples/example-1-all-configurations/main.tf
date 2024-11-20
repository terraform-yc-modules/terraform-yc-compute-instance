module "dev" {
  source                    = "../../"
  image_family              = "ubuntu-2204-lts-oslogin"
  zone                      = var.yc_zone
  name                      = "dev"
  hostname                  = "dev"
  description               = "dev"
  memory                    = 8
  gpus                      = 0
  cores                     = 4
  core_fraction             = 100
  serial_port_enable        = true
  allow_stopping_for_update = true
  monitoring                = true
  backup                    = false
  boot_disk = {
    size        = 30
    block_size  = 4096
    type        = "network-ssd"
    image_id    = null
    snapshot_id = null
  }
  secondary_disks = [
    {
      disk_id     = null
      auto_delete = true
      device_name = "secondary-disk"
      mode        = "READ_WRITE"
      size        = 100
      block_size  = 4096
      type        = "network-hdd"
    }
  ]
  filesystems = [
    {
      filesystem_id = null
      mode          = "READ_WRITE"
      zone          = var.yc_zone
    }
  ]

  enable_oslogin_or_ssh_keys = {
    enable-oslogin = "true"
    ssh_key        = null
    ssh_user       = null
  }
  network_interfaces = [
    {
      subnet_id = yandex_vpc_subnet.sub_a.id
      ipv4      = true
      nat       = true

    },
    {
      subnet_id  = yandex_vpc_subnet.sub_a.id
      ipv4       = true
      nat        = false
      dns_record = []
    }
  ]
  labels = {
    environment = "development"
    scope       = "dev"
  }
  static_ip = {
    name        = "my-static-ip"
    description = "Static IP for dev instance"
    external_ipv4_address = {
      zone_id = var.yc_zone
    }
  }
}
