# ADR-0001: IaC stack and state backend

- **Status**: Accepted
- **Date**: 2026-05-10
- **Decided by**: @dhopkalo

## Context

The InnoVestrum org needs a place to register and manage shared infrastructure (domain, DNS, email, GitHub config, future Workspace, future cross-product GCP foundations). Three pre-existing constraints fix most of the choice:

- The org already runs on GCP (the Cruiso product project has been live since Stage 0).
- The maintainer prefers GCP-native tooling where pricing and ergonomics are comparable (see the Cloud Domains vs Cloudflare Registrar comparison earlier in the conversation that led to this repo).
- Per-product infrastructure stays with its product; only org-level concerns belong here.

## Decision

- **IaC tool**: Terraform 1.13 (HashiCorp BUSL build), pinned via `terraform/versions.tf`. CI runs the same version via `hashicorp/setup-terraform` to keep formatter and parser identical to local.
- **State backend**: GCS, bucket `gs://innovestrum-tf-state`, EU region, versioned, uniform IAM. Single state file — no workspaces. Locking via the GCS backend's built-in object-level locks.
- **GCP project**: dedicated `innovestrum` project (number 946076038275), distinct from product projects. The state bucket and every resource managed by this repo live in it.
- **Apply path**: manual, by a maintainer with `roles/owner` on the `innovestrum` project, using their own gcloud Application Default Credentials. CI runs `fmt`, `validate`, and (once Workload Identity Federation lands — see *Consequences*) `plan`. CI never applies.

## Consequences

- A single state file is simple to reason about now; if cross-team operations ever block on locking, splitting by concern (domain/DNS, GitHub config, Workspace) becomes the next move.
- WHOIS contact info, billing details, and any future secret material live in `terraform.tfvars` (gitignored) on the maintainer's workstation, plus inside the state bucket. Treat the bucket like a credentials vault.
- Manual apply is the right starting point — it's the smallest path to a registered domain. It also means no CI plan output is available against real state until WIF is wired.
- **Follow-up**: file a tracking issue for "Workload Identity Federation for terraform-ci" once the manual flow has run end-to-end at least once. WIF lets CI generate `plan` previews against live state without copying a service-account key into GitHub.

## Alternatives considered

- **OpenTofu** instead of Terraform — same surface area, MPL license. Practical difference is small; chose Terraform for the broader ecosystem of providers and CI actions, with the option to swap later if HashiCorp licensing materially shifts again.
- **Cloudflare Registrar + Cloudflare DNS + Cloudflare Email Routing** — at-cost domain, free DNS, free email forwarding. Rejected because it adds a third party outside GCP for a $2/yr saving; conflicts with the GCP-native principle.
- **HCP Terraform (Terraform Cloud) free tier** for state — adds a third-party dependency outside GCP, same objection as above. The free tier also caps at 5 users, which makes it awkward as the org grows.
- **State bucket inside the `cruiso` GCP project** — conflates org-level resources with the Cruiso product. Painful to undo if Cruiso is ever transferred or its project lifecycle diverges.
