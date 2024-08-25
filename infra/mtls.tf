locals {
  certificate_folder_name = replace(var.zone_name, ".", "-")
}

##
# Private key
##
resource "tls_private_key" "this" {
  for_each = var.mtls_certificate_users

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  for_each = var.mtls_certificate_users

  filename = "../mtls-certificates/${local.certificate_folder_name}/${each.key}.key"
  content  = tls_private_key.this[each.key].private_key_pem
}

##
# Certificate signing request
##
resource "tls_cert_request" "this" {
  for_each = var.mtls_certificate_users

  private_key_pem = tls_private_key.this[each.key].private_key_pem

  subject {
    common_name  = "${var.mtls_certificate_configuration.common_name} - ${each.key}"
    organization = var.mtls_certificate_configuration.organization
    locality     = var.mtls_certificate_configuration.locality
    postal_code  = var.mtls_certificate_configuration.postal_code
    province     = var.mtls_certificate_configuration.province
    country      = var.mtls_certificate_configuration.country
  }
}

resource "local_file" "certificate_signing_request" {
  for_each = var.mtls_certificate_users

  filename = "../mtls-certificates/${local.certificate_folder_name}/${each.key}.csr"
  content  = tls_cert_request.this[each.key].cert_request_pem
}

##
# Certificate (.crt)
# Signed by Cloudflare CA
##
resource "restapi_object" "certificate" {
  for_each = var.mtls_certificate_users

  path = "/zones/${data.cloudflare_zone.this.id}/client_certificates"

  data = jsonencode({
    csr           = tls_cert_request.this[each.key].cert_request_pem
    validity_days = 3650
  })

  id_attribute = "result/id"

  force_new = [
    sha256(jsonencode({
      csr = tls_cert_request.this[each.key].cert_request_pem
    }))
  ]
}

resource "local_file" "certificate" {
  for_each = var.mtls_certificate_users

  filename = "../mtls-certificates/${local.certificate_folder_name}/${each.key}.crt"
  content  = jsondecode(restapi_object.certificate[each.key].api_response).result.certificate
}

##
# P12
##
resource "pkcs12_from_pem" "mtls" {
  for_each = var.mtls_certificate_users

  cert_pem        = local_file.certificate[each.key].content
  private_key_pem = tls_private_key.this[each.key].private_key_pem

  password = each.key

  encoding = "legacyDES"
}

resource "local_file" "p12" {
  for_each = var.mtls_certificate_users

  filename       = "../mtls-certificates/${local.certificate_folder_name}/${each.key}.p12"
  content_base64 = pkcs12_from_pem.mtls[each.key].result
}

##
# Cloudflare configuration
##

# Update hostname list for association
resource "restapi_object" "hostnames" {
  path = "/zones/${data.cloudflare_zone.this.id}/certificate_authorities/hostname_associations"

  data = jsonencode({
    hostnames = var.mtls_hostnames[*].domain_name
  })

  create_method = "PUT"

  destroy_method = "PUT"
  destroy_path   = "/zones/${data.cloudflare_zone.this.id}/certificate_authorities/hostname_associations"
  destroy_data = jsonencode({
    hostnames = []
  })

  update_method = "PUT"
  update_path   = "/zones/${data.cloudflare_zone.this.id}/certificate_authorities/hostname_associations"
  update_data = jsonencode({
    hostnames = var.mtls_hostnames[*].domain_name
  })

  read_method = "GET"
  read_path   = "/zones/${data.cloudflare_zone.this.id}/certificate_authorities/hostname_associations"
  read_data   = null

  object_id = "0"
}

# Enable client_certificate_forwarding option
resource "restapi_object" "certificate_forwarding" {
  for_each = { for hostname in var.mtls_hostnames : hostname.domain_name => hostname
  if var.mtls_client_certificate_forwarding }

  path = "/zones/${data.cloudflare_zone.this.id}/access/certificates/settings"

  data = jsonencode({
    settings = [{
      china_network                 = false
      client_certificate_forwarding = true
      hostname                      = each.key
      }
    ]
  })

  create_method = "PUT"

  read_path   = "/zones/${data.cloudflare_zone.this.id}/access/certificates/settings"
  read_method = "GET"
  read_data   = null

  update_method = "PUT"
  update_path   = "/zones/${data.cloudflare_zone.this.id}/access/certificates/settings"
  update_data = jsonencode({
    settings = [{
      china_network                 = false
      client_certificate_forwarding = true
      hostname                      = each.key
      }
    ]
  })

  destroy_path   = "/zones/${data.cloudflare_zone.this.id}/access/certificates/settings"
  destroy_method = "PUT"
  destroy_data = jsonencode({
    settings = [{
      china_network                 = false
      client_certificate_forwarding = false
      hostname                      = each.key
      }
    ]
  })

  id_attribute = "result/0/hostname"
}
