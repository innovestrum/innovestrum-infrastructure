# Forward Email free tier. Receives mail at any *@${domain} alias and
# forwards to a single destination (or per-alias destinations). No SMTP-send
# capability — replies go from the destination's own provider (Gmail, etc.).
#
# Provider docs: https://forwardemail.net/en/free-email-forwarding
# Caps on free tier: 50 aliases / domain, 10 MB attachments, no API.

locals {
  # Each alias forwards to its override (if non-null) or the default destination.
  email_alias_pairs = [
    for local_part, override in var.email_aliases :
    "${local_part}:${coalesce(override, var.email_forward_destination)}"
  ]
}

resource "google_dns_record_set" "mx" {
  managed_zone = google_dns_managed_zone.apex.name
  name         = google_dns_managed_zone.apex.dns_name
  type         = "MX"
  ttl          = 3600
  rrdatas = [
    "10 mx1.forwardemail.net.",
    "10 mx2.forwardemail.net.",
  ]
}

resource "google_dns_record_set" "spf" {
  managed_zone = google_dns_managed_zone.apex.name
  name         = google_dns_managed_zone.apex.dns_name
  type         = "TXT"
  ttl          = 3600
  # SPF + per-alias Forward Email rules. HCL doesn't allow mixing literals and
  # `for` expressions inside a single list, so concat the two halves.
  rrdatas = concat(
    ["\"v=spf1 a mx include:spf.forwardemail.net -all\""],
    [for pair in local.email_alias_pairs : "\"forward-email=${pair}\""]
  )
}

resource "google_dns_record_set" "dmarc" {
  managed_zone = google_dns_managed_zone.apex.name
  name         = "_dmarc.${google_dns_managed_zone.apex.dns_name}"
  type         = "TXT"
  ttl          = 3600
  # p=none = monitor only. Tighten to `quarantine` once we send any outgoing
  # mail from the domain (i.e. once Workspace or an SMTP provider is wired);
  # `reject` after a clean week of monitoring with no failed legitimate sends.
  rrdatas = ["\"v=DMARC1; p=none; rua=mailto:${var.email_forward_destination}\""]
}
