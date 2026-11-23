locals {
  service_account_name       = var.name != null ? var.name : "sa-${random_string.unique_id.result}"
  install_monitoring_agent   = var.install_monitoring_agent != null ? var.install_monitoring_agent : var.monitoring
  install_backup_agent       = var.install_backup_agent != null ? var.install_backup_agent : var.backup
  manage_service_account_iam = var.manage_service_account_iam != null ? var.manage_service_account_iam : var.service_account_id == null
  manage_monitoring_iam      = local.manage_service_account_iam && (var.monitoring || local.install_monitoring_agent)
  manage_backup_iam          = local.manage_service_account_iam && (var.backup || local.install_backup_agent)
  create_sa                  = var.service_account_id == null && (local.manage_monitoring_iam || local.manage_backup_iam)
  instance_service_account_id = var.service_account_id != null ? var.service_account_id : (
    local.create_sa ? yandex_iam_service_account.sa_instance[0].id : null
  )
}


resource "yandex_iam_service_account" "sa_instance" {
  count       = local.create_sa ? 1 : 0
  name        = local.service_account_name
  description = "Service account for monitoring and backup"
  folder_id   = local.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa_monitoring" {
  count     = local.manage_monitoring_iam ? 1 : 0
  folder_id = local.folder_id
  role      = "monitoring.editor"
  member    = "serviceAccount:${local.instance_service_account_id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa_backup" {
  count     = local.manage_backup_iam ? 1 : 0
  folder_id = local.folder_id
  role      = "backup.editor"
  member    = "serviceAccount:${local.instance_service_account_id}"
}
