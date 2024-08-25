terraform {
  encryption {
    key_provider "pbkdf2" "encryption_key" {
      passphrase = var.encryption_passphrase
    }

    method "aes_gcm" "encryption_method" {
      keys = key_provider.pbkdf2.encryption_key
    }

    state {
      method   = method.aes_gcm.encryption_method
      enforced = true
    }

    plan {
      method   = method.aes_gcm.encryption_method
      enforced = true
    }
  }
}
