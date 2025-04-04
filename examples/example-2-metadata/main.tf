module "dev" {
  source                    = "../../"
  image_family              = "ubuntu-2204-lts"
  zone                      = var.yc_zone
  name                      = "dev-2"
  hostname                  = "dev-2"
  description               = "dev-2"
  memory                    = 4
  gpus                      = 0
  cores                     = 2
  core_fraction             = 100
  serial_port_enable        = true
  allow_stopping_for_update = true

  boot_disk = {
    size       = 30
    block_size = 4096
    type       = "network-ssd"

  }
  enable_oslogin_or_ssh_keys = {
    ssh_user = "devops"
    ssh_key  = "~/.ssh/id_rsa.pub"
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
}
