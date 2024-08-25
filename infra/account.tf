data "cloudflare_accounts" "current" {}

locals {
  account_id = data.cloudflare_accounts.current.accounts[0].id
}
