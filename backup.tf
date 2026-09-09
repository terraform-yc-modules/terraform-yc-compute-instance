data "yandex_backup_policy" "this_backup_policy" {
  count = var.backup && var.backup_policy_id == null ? 1 : 0
  name  = var.backup_frequency
}

resource "yandex_backup_policy_bindings" "this" {
  count       = var.backup && var.backup_policy_id == null ? 1 : 0
  instance_id = yandex_compute_instance.this.id
  policy_id   = data.yandex_backup_policy.this_backup_policy[0].id
}

resource "yandex_backup_policy_bindings" "this_backup_binding" {
  count       = var.backup && var.backup_policy_id != null ? 1 : 0
  instance_id = yandex_compute_instance.this.id
  policy_id   = var.backup_policy_id
}
