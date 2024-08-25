locals {
  mtls_waf_rule_hostnames = [
    for hostname in var.mtls_hostnames : hostname.domain_name if hostname.create_mtls_waf_rule
  ]

  mtls_rule_waf_expression = <<EOT
not (
  cf.tls_client_auth.cert_verified and 
  not cf.tls_client_auth.cert_revoked and 
  cf.tls_client_auth.cert_subject_dn contains "O=${var.mtls_certificate_configuration.organization}" and 
  cf.tls_client_auth.cert_subject_dn contains "L=${var.mtls_certificate_configuration.locality}" and 
  cf.tls_client_auth.cert_subject_dn contains "ST=${var.mtls_certificate_configuration.province}" and 
  cf.tls_client_auth.cert_subject_dn contains "C=${var.mtls_certificate_configuration.country}"
) and (
    http.host in {"${join("\" \"", local.mtls_waf_rule_hostnames)}"}
)
EOT

  geolocation_rule_waf_expression = <<EOT
(
  not ip.geoip.country in {"${join("\" \"", var.waf_geolocation_whitelist_rule.restricted_countries)}"}
) and (
  http.host in {"${join("\" \"", var.waf_geolocation_whitelist_rule.domain_names)}"}
)
EOT

  ip_whitelist_rule_waf_expression = <<EOT
(
  not ip.src in {${join(" ", var.waf_ip_whitelist_rule.restricted_ips)}}
) and (
  http.host in {"${join("\" \"", var.waf_ip_whitelist_rule.domain_names)}"}
)
EOT
}

resource "cloudflare_ruleset" "waf" {
  zone_id = data.cloudflare_zone.this.id

  name        = "Custom rules"
  description = "Rules to override Cloudflare WAF"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  dynamic "rules" {
    for_each = length(var.mtls_hostnames) > 0 ? [1] : []

    content {
      action      = "block"
      expression  = local.mtls_rule_waf_expression
      description = "mTLS protection"
      enabled     = true
    }
  }

  dynamic "rules" {
    for_each = length(var.waf_geolocation_whitelist_rule.domain_names) > 0 ? [1] : []

    content {
      action      = "block"
      expression  = local.geolocation_rule_waf_expression
      description = "Country whitelist"
      enabled     = true
    }
  }

  dynamic "rules" {
    for_each = length(var.waf_ip_whitelist_rule.domain_names) > 0 ? [1] : []

    content {
      action      = "block"
      expression  = local.ip_whitelist_rule_waf_expression
      description = "IP address whitelist"
      enabled     = true
    }
  }

  dynamic "rules" {
    for_each = var.waf_custom_rules
    iterator = rule

    content {
      action      = rule.value.action
      expression  = rule.value.expression
      description = rule.value.description
      enabled     = rule.value.enabled
    }
  }
}
