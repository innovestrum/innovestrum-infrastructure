resource "google_dns_managed_zone" "apex" {
  name        = replace(var.domain_name, ".", "-")
  dns_name    = "${var.domain_name}."
  description = "Apex zone for ${var.domain_name}. Authoritative for all records on the apex and subdomains."

  # TODO: enable DNSSEC + register DS records with Cloud Domains (`ds_records`
  # block on google_clouddomains_registration). Requires a two-stage apply:
  # 1. zone with dnssec=on, fetch DS records from Cloud DNS, 2. add ds_records
  # to the registration. Filed as follow-up; not blocking the first apply.
  dnssec_config {
    state = "off"
  }

  depends_on = [google_project_service.dns]
}
