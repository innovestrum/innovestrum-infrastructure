# APIs were enabled at bootstrap time via `gcloud services enable`. Importing
# them under Terraform's management here keeps the repo authoritative for the
# project's API surface — manual `gcloud services disable` would now fail
# `terraform plan`.

resource "google_project_service" "domains" {
  service            = "domains.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "dns" {
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudresourcemanager" {
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "serviceusage" {
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
}
