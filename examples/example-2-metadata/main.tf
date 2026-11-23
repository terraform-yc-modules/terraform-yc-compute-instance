module "dev" {
  source                    = "../../"
  image_family              = "ubuntu-2204-lts"
  zone                      = var.yc_zone
  name                      = format("%sdev-2", var.name_prefix == null ? "" : var.name_prefix)
  hostname                  = format("%sdev-2", var.name_prefix == null ? "" : var.name_prefix)
  description               = "dev-2"
  memory                    = var.memory
  gpus                      = 0
  cores                     = var.cores
  core_fraction             = 100
  serial_port_enable        = true
  allow_stopping_for_update = true

  boot_disk = {
    size       = var.boot_disk_size
    block_size = 4096
    type       = "network-ssd"

  }
  enable_oslogin_or_ssh_keys = {
    enable-oslogin = var.ssh_public_key == null ? "true" : "false"
    ssh_user       = var.ssh_public_key == null ? null : "devops"
    ssh_public_key = var.ssh_public_key
  }
  user_data = var.user_data
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
}
