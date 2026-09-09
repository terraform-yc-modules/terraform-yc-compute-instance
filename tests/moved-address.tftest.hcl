mock_provider "random" {}

mock_provider "yandex" {}

run "apply_legacy_singleton_boot_disk" {
  command   = apply
  state_key = "legacy-singleton-boot-disk"

  module {
    source = "./tests/fixtures/legacy_boot_disk"
  }

  override_resource {
    target = yandex_compute_disk.this
    values = {
      id = "legacy-boot-disk-id"
    }
    override_during = apply
  }
}

run "plan_refactored_counted_boot_disk_with_legacy_state" {
  command   = plan
  state_key = "legacy-singleton-boot-disk"

  variables {
    name      = "legacy-boot-disk"
    folder_id = "test-folder"
    zone      = "ru-central1-a"

    enable_oslogin_or_ssh_keys = {
      enable-oslogin = "true"
    }

    network_interfaces = [{
      subnet_id = "test-subnet"
      nat       = true
    }]
  }

  assert {
    condition     = yandex_compute_disk.this[0].id == "legacy-boot-disk-id"
    error_message = "The legacy yandex_compute_disk.this state must move to yandex_compute_disk.this[0] without replacement."
  }
}
