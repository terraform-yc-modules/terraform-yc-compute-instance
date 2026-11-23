mock_provider "random" {}

mock_provider "yandex" {}

run "secondary_disks_null_preserves_the_legacy_empty_disk_set" {
  command = plan

  variables {
    name      = "secondary-disks-null-regression"
    folder_id = "test-folder"
    zone      = "ru-central1-a"

    enable_oslogin_or_ssh_keys = {
      enable-oslogin = "true"
    }

    network_interfaces = [{
      subnet_id = "test-subnet"
      nat       = true
    }]

    secondary_disks = null
  }

  assert {
    condition     = output.secondary_disk_ids == []
    error_message = "secondary_disks=null must preserve the legacy empty secondary disk set."
  }
}
