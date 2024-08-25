locals {
  pages_custom_domains = flatten([
    for project in var.pages : [
      for custom_domain in project.custom_domains : {
        project_name = project.name
        domain       = custom_domain.domain
        branch       = custom_domain.branch
      }
    ]
  ])
}

##
# Project
##
resource "cloudflare_pages_project" "this" {
  for_each = { for project in var.pages : project.name => project }

  account_id = local.account_id

  name              = each.value.name
  production_branch = each.value.production_branch

  dynamic "source" {
    for_each = each.value.source != null ? [each.value.source] : []

    content {
      type = source.value.type

      config {
        owner             = source.value.config.owner
        repo_name         = source.value.config.repo_name
        production_branch = source.value.config.production_branch

        pr_comments_enabled           = source.value.config.pr_comments_enabled
        deployments_enabled           = source.value.config.deployments_enabled
        production_deployment_enabled = source.value.config.production_deployment_enabled

        preview_deployment_setting = source.value.config.preview_deployment_setting
        preview_branch_includes    = source.value.config.preview_branch_includes
        preview_branch_excludes    = source.value.config.preview_branch_excludes
      }
    }
  }

  dynamic "build_config" {
    for_each = each.value.build_config != null ? [each.value.build_config] : []
    iterator = build

    content {
      build_command   = build.value.build_command
      destination_dir = build.value.destination_dir
      root_dir        = build.value.root_dir
    }
  }
}

##
# Custom domains
##
resource "cloudflare_pages_domain" "this" {
  for_each = { for pages_custom_domain in local.pages_custom_domains : pages_custom_domain.domain => pages_custom_domain }

  account_id = local.account_id

  project_name = each.value.project_name
  domain       = each.value.domain

  depends_on = [
    cloudflare_pages_project.this,
  ]
}

resource "cloudflare_record" "pages" {
  for_each = { for pages_custom_domain in local.pages_custom_domains : pages_custom_domain.domain => pages_custom_domain }

  zone_id = data.cloudflare_zone.this.id

  priority = 500 + index(local.pages_custom_domains, each.value)

  name    = each.value.domain
  content = each.value.branch != "main" ? "${each.value.branch}.${cloudflare_pages_project.this[each.value.project_name].subdomain}" : cloudflare_pages_project.this[each.value.project_name].subdomain
  type    = "CNAME"
  ttl     = 0
  proxied = true

  lifecycle {
    ignore_changes = [
      ttl,
      allow_overwrite,
    ]
  }
}

##
# DNS validation
##
resource "restapi_object" "pages_dns_validation" {
  for_each = { for pages_custom_domain in local.pages_custom_domains : pages_custom_domain.domain => pages_custom_domain }

  path = "/accounts/${local.account_id}/pages/projects/${each.value.project_name}/domains/${each.value.domain}"
  data = ""

  create_method = "PATCH"

  update_method = "PATCH"
  update_path   = "/accounts/${local.account_id}/pages/projects/${each.value.project_name}/domains/${each.value.domain}"
  update_data   = null

  destroy_method = "PATCH"
  destroy_path   = "/accounts/${local.account_id}/pages/projects/${each.value.project_name}/domains/${each.value.domain}"
  destroy_data   = null

  object_id = each.value.domain

  depends_on = [
    cloudflare_pages_domain.this,
    cloudflare_record.pages,
  ]
}
