resource "cloudflare_record" "this" {
  for_each = { for record in var.dns_records : "${record.name}-${lower(record.type)}" => record }

  zone_id = data.cloudflare_zone.this.id

  priority = index(var.dns_records, each.value)

  name    = each.value.name
  content = each.value.value
  type    = each.value.type
  ttl     = each.value.ttl
  proxied = each.value.proxied
  comment = each.value.comment

  lifecycle {
    ignore_changes = [
      ttl,
      allow_overwrite,
    ]
  }
}


resource "cloudflare_zone_dnssec" "this" {
  zone_id = data.cloudflare_zone.this.id
}
