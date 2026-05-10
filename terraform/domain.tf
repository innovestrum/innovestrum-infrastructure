# Cloud Domains registration. The yearly_price block must match exactly what
# `gcloud domains registrations search-domains <domain>` returns at apply time
# — Terraform compares it before submitting the registration.
#
# After apply: state="REGISTRATION_PENDING" briefly, then "ACTIVE" within minutes.
# Auto-renewal is on by default; transfer is locked to prevent accidental
# transfer-out (unlock manually in the Console when intentionally migrating).

locals {
  # All three contact roles use the same data for a one-maintainer setup.
  contact_block = {
    phone_number = var.registrant_phone_number
    email        = var.registrant_email
    postal_address = {
      region_code         = var.registrant_postal_address.region_code
      postal_code         = var.registrant_postal_address.postal_code
      administrative_area = var.registrant_postal_address.administrative_area
      locality            = var.registrant_postal_address.locality
      address_lines       = var.registrant_postal_address.address_lines
      recipients          = var.registrant_postal_address.recipients
    }
  }
}

resource "google_clouddomains_registration" "apex" {
  domain_name = var.domain_name
  location    = "global"

  yearly_price {
    currency_code = "USD"
    units         = var.domain_yearly_price_usd
  }

  contact_settings {
    privacy = "REDACTED_CONTACT_DATA"

    registrant_contact {
      phone_number = local.contact_block.phone_number
      email        = local.contact_block.email
      postal_address {
        region_code         = local.contact_block.postal_address.region_code
        postal_code         = local.contact_block.postal_address.postal_code
        administrative_area = local.contact_block.postal_address.administrative_area
        locality            = local.contact_block.postal_address.locality
        address_lines       = local.contact_block.postal_address.address_lines
        recipients          = local.contact_block.postal_address.recipients
      }
    }

    admin_contact {
      phone_number = local.contact_block.phone_number
      email        = local.contact_block.email
      postal_address {
        region_code         = local.contact_block.postal_address.region_code
        postal_code         = local.contact_block.postal_address.postal_code
        administrative_area = local.contact_block.postal_address.administrative_area
        locality            = local.contact_block.postal_address.locality
        address_lines       = local.contact_block.postal_address.address_lines
        recipients          = local.contact_block.postal_address.recipients
      }
    }

    technical_contact {
      phone_number = local.contact_block.phone_number
      email        = local.contact_block.email
      postal_address {
        region_code         = local.contact_block.postal_address.region_code
        postal_code         = local.contact_block.postal_address.postal_code
        administrative_area = local.contact_block.postal_address.administrative_area
        locality            = local.contact_block.postal_address.locality
        address_lines       = local.contact_block.postal_address.address_lines
        recipients          = local.contact_block.postal_address.recipients
      }
    }
  }

  dns_settings {
    custom_dns {
      name_servers = google_dns_managed_zone.apex.name_servers
    }
  }

  management_settings {
    renewal_method      = "AUTOMATIC_RENEWAL"
    transfer_lock_state = "LOCKED"
  }

  labels = {
    managed_by = "terraform"
    repo       = "innovestrum-infrastructure"
  }

  depends_on = [google_project_service.domains]

  # Domain registration is a financial transaction — make `terraform destroy`
  # think twice before deleting (which would also delete the registration on
  # the registry side). Manual unlock required to ever destroy.
  lifecycle {
    prevent_destroy = true
  }
}
