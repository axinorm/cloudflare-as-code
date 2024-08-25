terraform {
  required_version = "~> 1.8.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.39.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.19.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
    pkcs12 = {
      source  = "chilicat/pkcs12"
      version = "~> 0.2.0"
    }
  }
}

provider "cloudflare" {}

provider "restapi" {
  uri = "https://api.cloudflare.com/client/v4"

  write_returns_object = true

  headers = {
    "Authorization" : "Bearer ${var.cloudflare_api_token}",
    "Content-Type" = "application/json"
  }
}
