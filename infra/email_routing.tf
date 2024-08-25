resource "cloudflare_email_routing_settings" "this" {
  count = length(var.email_routing_rules) > 0 ? 1 : 0

  zone_id = data.cloudflare_zone.this.id

  enabled = "true"
}

resource "cloudflare_email_routing_rule" "this" {
  for_each = { for rule in var.email_routing_rules : rule.name => rule }

  zone_id = data.cloudflare_zone.this.id

  name    = each.key
  enabled = each.value.enabled

  matcher {
    type  = each.value.matcher.type
    field = each.value.matcher.field
    value = each.value.matcher.value
  }

  action {
    type  = each.value.action.type
    value = each.value.action.value
  }
}

resource "cloudflare_email_routing_address" "this" {
  for_each = toset(flatten(var.email_routing_rules[*].action.value))

  account_id = local.account_id

  email = each.key
}
