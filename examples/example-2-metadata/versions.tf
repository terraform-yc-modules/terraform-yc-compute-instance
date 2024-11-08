terraform {
  required_version = ">= 0.13"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "= 0.127"
    }
  }
}
provider "yandex" {
  zone = "ru-central1"
}


provider "local" {}

provider "random" {}