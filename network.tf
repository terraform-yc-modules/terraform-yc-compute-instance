

resource "yandex_vpc_address" "static_ip" {
  count = var.static_ip != null ? 1 : 0
  name               = "${var.name}-${random_string.unique_id.result}"
  description               = var.static_ip.description
  folder_id                 = local.folder_id
  deletion_protection       = var.static_ip.deletion_protection
  labels             = var.labels
  external_ipv4_address {
    zone_id                   = var.static_ip.external_ipv4_address.zone_id
    ddos_protection_provider  = var.static_ip.external_ipv4_address.ddos_protection_provider
    outgoing_smtp_capability  = var.static_ip.external_ipv4_address.outgoing_smtp_capability
  }

  dynamic "dns_record" {
    for_each = var.static_ip.dns_record != null ? [var.static_ip.dns_record] : []
    content {
      fqdn        = dns_record.value.fqdn
      dns_zone_id = dns_record.value.dns_zone_id
      ttl         = lookup(dns_record.value, "ttl", null)
      ptr         = lookup(dns_record.value, "ptr", false)
    }
  }
}