output "domain_name" {
  description = "Registered apex domain."
  value       = google_clouddomains_registration.apex.domain_name
}

output "domain_state" {
  description = "Registration state — should reach ACTIVE within minutes of apply."
  value       = google_clouddomains_registration.apex.state
}

output "managed_zone_name_servers" {
  description = "Cloud DNS name servers authoritative for the zone. The registration is configured to point at these — no manual delegation step needed."
  value       = google_dns_managed_zone.apex.name_servers
}

output "email_aliases_active" {
  description = "Aliases configured to forward via Forward Email. Test by sending mail to any of these."
  value       = [for local_part in keys(var.email_aliases) : "${local_part}@${var.domain_name}"]
}
