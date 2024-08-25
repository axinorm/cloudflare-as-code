##
# Encryption
##
variable "encryption_passphrase" {
  type        = string
  description = "Passphrase for encrypting state and plan files"
}

##
# Global
##
variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token for restapi provider"
}

variable "zone_name" {
  type        = string
  description = "Cloudflare zone name"
}

##
# Settings
##
variable "zone_settings" {
  type = object({
    always_online            = string
    always_use_https         = string
    automatic_https_rewrites = string
    brotli                   = string
    early_hints              = string
    email_obfuscation        = string
    fonts                    = string
    http3                    = string
    ip_geolocation           = string
    min_tls_version          = string
    ssl                      = string
    rocket_loader            = string
    tls_1_3                  = string
    websockets               = string
    zero_rtt                 = string
  })
  description = "Cloudflare zone settings"
}

##
# DNS
##
variable "dns_records" {
  type = list(object({
    name    = string,
    value   = string,
    type    = string,
    ttl     = optional(number, 0),
    proxied = optional(bool, true),
    comment = optional(string, null),
  }))
}

##
# mTLS
##
variable "mtls_certificate_configuration" {
  type = object({
    common_name  = string
    organization = string
    locality     = string
    postal_code  = string
    province     = string
    country      = string
  })
  description = "mTLS certificate configuration"
}

variable "mtls_certificate_users" {
  type        = set(string)
  description = "List of users to create mtls certificates"
}

variable "mtls_hostnames" {
  type = list(object({
    domain_name          = string
    create_mtls_waf_rule = optional(bool, true)
  }))
  description = "List of hostnames to secure with mTLS"
}

variable "mtls_client_certificate_forwarding" {
  type        = bool
  description = "Enable client certificate forwarding"
}

##
# WAF
##
variable "waf_ip_whitelist_rule" {
  type = object({
    restricted_ips = list(string)
    domain_names   = list(string)
  })
  description = " White list of IPs to secure domain names"
}

variable "waf_geolocation_whitelist_rule" {
  type = object({
    restricted_countries = list(string)
    domain_names         = list(string)
  })
  description = " White list of countries to secure domain names"
}

variable "waf_custom_rules" {
  type = list(object({
    action      = string
    expression  = string
    description = string
    enabled     = bool
  }))
  description = "List of custom WAF rules"
}

##
# Email routing
##
variable "email_routing_rules" {
  type = list(object({
    name    = string
    enabled = bool
    matcher = object({
      type  = string
      field = string
      value = string
    })
    action = object({
      type  = string
      value = list(string)
    })
  }))
  description = "Rules for email routing service"
  default     = []
}

##
# Pages
##
variable "pages" {
  type = list(object({
    name              = string
    production_branch = string
    custom_domains = list(object({
      domain = string
      branch = optional(string, "main")
    }))
    source = optional(object({
      type = string
      config = object({
        owner                         = string
        repo_name                     = string
        production_branch             = string
        pr_comments_enabled           = optional(bool, true)
        deployments_enabled           = optional(bool, true)
        production_deployment_enabled = optional(bool, true)
        preview_deployment_setting    = string
        preview_branch_includes       = list(string)
        preview_branch_excludes       = list(string)
      })
    }), null)
    build_config = optional(object({
      build_command   = string
      destination_dir = string
      root_dir        = string
    }), null)
  }))
  description = "List of pages projects"
  default     = []
}

##
# Rules
##
variable "configuration_rules" {
  type = list(object({
    action = string
    action_parameters = object({
      rocket_loader = optional(bool, true)
    })
    expression  = string
    description = string
    enabled     = bool
  }))
  description = "List of configuration rules"
  default     = []
}

variable "redirect_rules" {
  type = list(object({
    description           = string
    expression            = string
    dynamic_target_url    = string
    preserve_query_string = optional(bool, false)
    status_code           = optional(number, 301)
  }))
  description = "List of redirect rules"
  default     = []
}

variable "bulk_redirect_rules" {
  type = list(object({
    name                  = string
    description           = string
    source_url            = string
    target_url            = string
    include_subdomains    = optional(bool, false)
    preserve_query_string = optional(bool, false)
    status_code           = optional(number, 301)
  }))
  description = "List of bulk redirect rules"
  default     = []
}
