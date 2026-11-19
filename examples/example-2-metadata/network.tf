# VPC and Subnets
resource "yandex_vpc_network" "vpc" {
  name = format("%svpc-compute-instance-1", var.name_prefix == null ? "" : var.name_prefix)
}

resource "yandex_vpc_subnet" "sub_a" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = ["10.1.0.0/24"]
}
