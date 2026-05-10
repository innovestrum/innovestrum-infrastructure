variable "project_id" {
  description = "GCP project ID where org-level resources live."
  type        = string
  default     = "innovestrum"
}

variable "domain_name" {
  description = "Apex domain to register and manage."
  type        = string
  default     = "innovestrum.com"
}

variable "domain_yearly_price_usd" {
  description = "Yearly price quoted by Cloud Domains' search-domains API at apply time. Must match exactly or registration fails."
  type        = number
  default     = 12
}

# --- Contact details for WHOIS registration ---
# Cloud Domains requires registrant + admin + technical contacts. We pass one
# block and reuse it for all three roles below — they can be different people
# in larger orgs, but for a one-maintainer setup duplicating is honest.
#
# These values populate WHOIS records but are REDACTED publicly via
# `privacy = "REDACTED_CONTACT_DATA"` in domain.tf. Stored unredacted in state.
# Set them in `terraform.tfvars` (gitignored), never commit real values.

variable "registrant_email" {
  description = "Contact email for the registrant. Goes to WHOIS (redacted) and registry transfer challenges."
  type        = string
  sensitive   = true
}

variable "registrant_phone_number" {
  description = "E.164-formatted phone number, e.g. +34600000000."
  type        = string
  sensitive   = true
}

variable "registrant_postal_address" {
  description = "Postal address block matching Cloud Domains' schema."
  type = object({
    region_code         = string # ISO-3166 alpha-2, e.g. "ES"
    postal_code         = string
    administrative_area = optional(string) # state/province; leave null where not applicable
    locality            = string           # city
    address_lines       = list(string)
    recipients          = list(string)
  })
  sensitive = true
}

# --- Email forwarding ---

variable "email_forward_destination" {
  description = "Where to forward all aliased addresses on the domain (e.g. play@innovestrum.com → here)."
  type        = string
  sensitive   = true
}

variable "email_aliases" {
  description = "Map of local-part → destination override. Use null to forward to email_forward_destination."
  type        = map(string)
  default = {
    # user-facing
    hello   = null
    support = null
    billing = null
    press   = null
    # product / transactional
    play     = null
    appstore = null
    noreply  = null
    # compliance / technical
    legal      = null
    security   = null
    abuse      = null
    postmaster = null
  }
}
