resource "yandex_vpc_network" "this" {
  name = "${var.name_prefix}vpc"
}

resource "yandex_vpc_subnet" "this" {
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = ["10.4.0.0/24"]
}
