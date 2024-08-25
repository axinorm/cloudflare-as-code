resource "cloudflare_zone_settings_override" "this" {
  zone_id = data.cloudflare_zone.this.id

  dynamic "settings" {
    for_each = [var.zone_settings]
    iterator = setting

    content {
      always_online            = setting.value.always_online
      always_use_https         = setting.value.always_use_https
      automatic_https_rewrites = setting.value.automatic_https_rewrites
      brotli                   = setting.value.brotli
      early_hints              = setting.value.early_hints
      email_obfuscation        = setting.value.email_obfuscation
      fonts                    = setting.value.fonts
      http3                    = setting.value.http3
      ip_geolocation           = setting.value.ip_geolocation
      min_tls_version          = setting.value.min_tls_version
      ssl                      = setting.value.ssl
      rocket_loader            = setting.value.rocket_loader
      tls_1_3                  = setting.value.tls_1_3
      websockets               = setting.value.websockets
      zero_rtt                 = setting.value.zero_rtt
    }
  }
}
