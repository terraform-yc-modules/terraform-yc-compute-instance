module "dev" {
  source                    = "../../"
  image_family              = "ubuntu-2204-lts-oslogin"
  zone                      = var.yc_zone
  name                      = format("%sdev-1", var.name_prefix == null ? "" : var.name_prefix)
  hostname                  = format("%sdev-1", var.name_prefix == null ? "" : var.name_prefix)
  description               = "dev-1"
  memory                    = var.memory
  gpus                      = 0
  cores                     = var.cores
  core_fraction             = 100
  serial_port_enable        = true
  allow_stopping_for_update = true
  allow_recreate            = true
  monitoring                = true
  backup                    = true
  metadata_options = {
    aws_v2_http_endpoint = 2
    aws_v2_http_token    = 2
  }
  boot_disk = {
    size       = var.boot_disk_size
    block_size = 4096
    type       = "network-ssd"
  }
  secondary_disks = [
    {
      auto_delete = true
      device_name = "secondary-disk"
      mode        = "READ_WRITE"
      size        = var.secondary_disk_size
      block_size  = 4096
      type        = "network-hdd"
    }
  ]
  filesystems = [
    {
      mode = "READ_WRITE"
      zone = var.yc_zone
    }
  ]

  enable_oslogin_or_ssh_keys = {
    enable-oslogin = "true"
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
