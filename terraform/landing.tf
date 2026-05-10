# "Coming soon" landing page parking.
#
# Apex + www A records point at a temporary host (currently the dhcloud
# personal VM — see issue #3 for the migration plan to an independent host).
# TTL is intentionally short (300s) so a future cutover doesn't get stuck
# behind long caches.

resource "google_dns_record_set" "landing_apex_a" {
  managed_zone = google_dns_managed_zone.apex.name
  name         = google_dns_managed_zone.apex.dns_name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.landing_host_ipv4]
}

resource "google_dns_record_set" "landing_www_a" {
  managed_zone = google_dns_managed_zone.apex.name
  name         = "www.${google_dns_managed_zone.apex.dns_name}"
  type         = "A"
  ttl          = 300
  rrdatas      = [var.landing_host_ipv4]
}
