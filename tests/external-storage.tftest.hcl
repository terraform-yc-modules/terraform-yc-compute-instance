mock_provider "random" {}

mock_provider "yandex" {}

run "plan_with_fixture_owned_storage_ids" {
  command = plan

  module {
    source = "./tests/fixtures/external_storage"
  }
}
