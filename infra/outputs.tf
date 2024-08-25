output "zone_id" {
  value       = data.cloudflare_zone.this.id
  description = "Zone ID for domain"
}

output "dnssec_ds_record" {
  value = {
    key_tag    = cloudflare_zone_dnssec.this.key_tag,
    flags      = cloudflare_zone_dnssec.this.flags,
    algorithm  = cloudflare_zone_dnssec.this.algorithm,
    public_key = cloudflare_zone_dnssec.this.public_key
  }
  description = "DS Record for DNSSEC activation"
}

output "cdn_ip_ranges" {
  value = data.cloudflare_ip_ranges.this.cidr_blocks
}
