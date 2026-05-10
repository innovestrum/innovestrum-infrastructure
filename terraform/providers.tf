provider "google" {
  project = var.project_id
  # Cloud Domains is global; Cloud DNS zones are global resources too. The
  # provider region only matters for resources we don't manage here, so leave
  # it on the implicit default.
}
