locals {
  service_account_name = var.name != null ? var.name : "sa-${random_string.unique_id.result}"
  create_sa = var.service_account_id == null && (var.monitoring || var.backup)
}


resource "yandex_iam_service_account" "sa_instance" {
  count       = local.create_sa ? 1 : 0
  name        = local.service_account_name
  description = "Service account for monitoring and backup"
  folder_id   = local.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa_monitoring" {
  count     = local.create_sa && var.monitoring ? 1 : 0
  folder_id = local.folder_id
  role      = "monitoring.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa_instance[0].id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa_backup" {
  count     = local.create_sa && var.backup ?  1 : 0
  folder_id = local.folder_id
  role      = "backup.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa_instance[0].id}"
}

data "yandex_backup_policy" "this_backup_policy" {
  name  = var.backup_frequency
}

resource "yandex_backup_policy_bindings" "this_backup_binding" {
  count       = var.backup ? 1 : 0
  instance_id = yandex_compute_instance.this.id
  policy_id   = data.yandex_backup_policy.this_backup_policy.id
}
