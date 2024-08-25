##
# Global
##
zone_name = "example.org"

##
# Settings
##
zone_settings = {
  always_online            = "on"
  always_use_https         = "on"
  automatic_https_rewrites = "on"
  brotli                   = "on"
  early_hints              = "on" # Improve page load speeds
  email_obfuscation        = "on"
  fonts                    = "on"
  http3                    = "off" # Disabled to avoid mTLS issues
  ip_geolocation           = "on"
  min_tls_version          = "1.3"
  ssl                      = "full"
  rocket_loader            = "on"
  tls_1_3                  = "zrt"
  websockets               = "on"
  zero_rtt                 = "on"
}

##
# DNS
##
dns_records = [
  ##
  # A records
  ##
  { name = "server", value = "x.x.x.x", type = "A", proxied = true },
  ##
  # CNAME records
  ##
  { name = "website", value = "server.example.org", type = "CNAME", proxied = true },
  { name = "prometheus", value = "server.example.org", type = "CNAME", proxied = true },
]

##
# mTLS
##
mtls_certificate_configuration = {
  common_name  = "example.org"
  organization = "My organization"
  locality     = "My city"
  postal_code  = "00000"
  province     = ""
  country      = "US"
}

mtls_certificate_users = [
  "axinorm",
]

mtls_hostnames = [
  { domain_name = "server.example.org", create_mtls_waf_rule = true },
]

mtls_client_certificate_forwarding = true

##
# WAF
##
waf_ip_whitelist_rule = {
  restricted_ips = [
    "x.x.x.x/32",
  ]
  domain_names = [
    "server.example.org",
  ]
}

waf_geolocation_whitelist_rule = {
  restricted_countries = [
    "ES", # Spain
    "FR", # France
  ]
  domain_names = [
    "website.example.org",
  ]
}

waf_custom_rules = [
  {
    action      = "block"
    expression  = <<EOT
(
  http.request.uri.path contains "/admin" and http.host eq "website.example.org"
)
EOT
    description = "Website disable admin access"
    enabled     = true
  },
]

##
# Email routing
##
email_routing_rules = [
  {
    name    = "pro"
    enabled = true

    matcher = {
      type  = "literal"
      field = "to"
      value = "pro@example.org"
    }

    action = {
      type = "forward"
      value = [
        "admin@example.org",
      ]
    }
  },
]

##
# Pages
##
pages = [
  {
    name              = "blog"
    production_branch = "main"
    custom_domains = [
      {
        domain = "example.org"
        branch = "main"
      },
      {
        domain = "dev.example.org"
        branch = "dev"
      },
    ]
    source = {
      type = "github"
      config = {
        owner                         = "my_user"
        repo_name                     = "blog"
        production_branch             = "main"
        pr_comments_enabled           = true
        deployments_enabled           = true
        production_deployment_enabled = true
        preview_deployment_setting    = "custom"
        preview_branch_includes       = ["dev"]
        preview_branch_excludes       = ["main"]
      }
    }
  }
]
