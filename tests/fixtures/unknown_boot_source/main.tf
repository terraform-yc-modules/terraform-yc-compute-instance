resource "yandex_compute_disk" "source" {
  name = "fixture-unknown-boot-source"
  zone = "ru-central1-a"
  size = 30
}

module "this" {
  source = "../../.."

  name         = "unknown-boot-source-regression"
  folder_id    = "test-folder"
  zone         = "ru-central1-a"
  image_family = "standard"

  enable_oslogin_or_ssh_keys = {
    enable-oslogin = "true"
  }

  network_interfaces = [{
    subnet_id = "test-subnet"
    nat       = true
  }]

  boot_disk = {
    image_id = yandex_compute_disk.source.id
  }
}
