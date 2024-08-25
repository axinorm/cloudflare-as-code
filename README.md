# Cloudflare as code

Deploy your Cloudflare configuration easily with OpenTofu!

**Table of contents:**

* [API token permissions](#api-token-permissions)
* [Providers](#providers)
* [Backend](#backend)
* [Required variables](#required-variables)
* [Global configuration](#global-configuration)
* [Deploy](#deploy)
* [Blog posts](#blog-posts)

## API token permissions

In order to deploy your code, you have to generate an API token inside Cloudflare dashboard. To do so, go to your ``Profile`` > ``API Tokens`` > ``Create Token`` and add the following permissions:

* Account - Email Routing Addresses - Edit
* Account - Cloudflare Pages - Edit
* Account - Access: Mutual TLS Certificates - Edit
* Account - Workers Scripts - Edit
* Account - Account Settings - Read
* Account - Access: Apps and Policies - Edit
* Zone - Email Routing Rules - Edit
* Zone - Zone WAF - Edit
* Zone - Access: Apps and Policies - Edit
* Zone - Zone Settings - Edit
* Zone - Zone - Read
* Zone - SSL and Certificates - Edit
* Zone - DNS - Edit

## Providers

Multiple providers are used inside this code:

* ``cloudflare/cloudflare``: The official Cloudflare provider, to create most of the resources;
* ``Mastercard/restapi``: To use Cloudflare APIs if a resource or service is not available from the official provider;
* ``hashicorp/local``, ``hashicorp/tls`` and ``chilicat/pkcs12``: To generate and retrieve TLS certificates for mTLS configuration.

## Backend

The backend configuration (``infra/backend.tf``) inside this repository is configured to be local for simplicity, feel free to update it!

## Required variables

Before deploying code, you have to configure the following variables:

```sh
export CLOUDFLARE_API_TOKEN= # Your Cloudflare API token
export TF_VAR_cloudflare_api_token=$CLOUDFLARE_API_TOKEN
export TF_VAR_encryption_passphrase= # Your passphrase for state and plan encryption
```

## Global configuration

The configurations files are located in ``infra/configurations`` folder, you can duplicate the existing file with your domain name like ``my-domain-com.tfvars``.

Feel free to check out the example file (``example-org.tfvars``) in this folder to fill in your configuration with the required variables.

Inside this OpenTofu code, you can:

* Configure your Cloudflare zone with ``zone_name`` variable;
* Set up zone settings with ``settings`` variable. Disable ``http3`` option for mTLS to work properly due to [known limitation](https://developers.cloudflare.com/cloudflare-one/identity/devices/access-integrations/mutual-tls-authentication/#known-limitations);
* Define domain name records using ``dns_records`` variable;
* Create a mTLS configuration to protect your sensitive websites and create your own Cloudflare CA-signed certificates with ``mtls_certificate_users``, ``mtls_certificate_configuration`` and ``mtls_hostnames`` variables. The ``mtls_client_certificate_forwarding`` option enables Cloudflare to send two headers (``Cf-Client-Cert-Der-Base64`` and ``Cf-Client-Cert-Sha256``) to the origin if you want to check them.
* In the WAF section, you can:
  * Restrict IPs for certain domain names using ``waf_ip_whitelist_rule`` variable;
  * Restrict countries for some domain names using ``waf_geolocation_whitelist_rule`` variable;
  * Create your own custom WAF rules using ``waf_custom_rules`` variable.
* Create an email transfer using ``email_routing_rules`` variable;
* Configure pages projects with ``pages`` variable. Useful if you want to host static content such as a blog with Hugo;

## Deploy

To make code deployment easier, you can use the ``tofutil.sh`` script. However, as with classic OpenTofu code, you can use the following commands:

```sh
# Init backend and download providers
tofu init -backend-config=path= # To be configured with your backend path

# Validate your configuration
tofu validate -var-file= # To be configured with your configuration file

# Plan or Apply your configuration
tofu plan -var-file= # To be configured with your configuration file
tofu apply -var-file= # To be configured with your configuration file
```

## Blog posts

Don't hesitate to read the following blog posts to find out more about deploying Cloudflare configuration with OpenTofu:

* [Protect your services with Cloudflare and deploy your configurations with OpenTofu](https://blog.filador.fr/en/posts/protect-your-services-with-cloudflare-and-deploy-your-configurations-with-opentofu/) - English version
* [Protégez vos services avec Cloudflare et déployez vos configurations avec OpenTofu](https://blog.filador.fr/posts/protegez-vos-services-avec-cloudflare-et-deployez-vos-configurations-avec-opentofu/) - French version
