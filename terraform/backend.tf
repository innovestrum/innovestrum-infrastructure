terraform {
  backend "gcs" {
    bucket = "innovestrum-tf-state"
    prefix = "org-infrastructure"
  }
}
