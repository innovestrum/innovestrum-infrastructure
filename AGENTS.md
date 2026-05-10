# AGENTS.md — Rules for AI Agents Working on InnoVestrum Infrastructure

This file is the briefing for any AI coding agent acting on this repository. Read it before doing anything.

> Conflicts with anything else? This file wins. Open a PR to fix the conflict — never silently work around it.

---

## 1. Scope discipline

This repo owns **org-level** infrastructure only — domain, DNS, email, shared GCP foundations, GitHub org config. Per-product resources (Cruiso's GCP project, app-specific Cloud Run services, etc.) live next to the product code, not here. If you can't answer "would every InnoVestrum product need this?" with yes, it doesn't belong here.

## 2. Branch & PR rules

- Trunk-based. `main` is always plan-clean (`terraform plan` produces no diff with the latest `terraform.tfvars` in the maintainer's checkout).
- Work on `feature/<issue-id>-<slug>` branches.
- **Every PR references a GitHub issue** in its body (`Closes #N` / `Refs #N`).
- Squash-merge only.
- PR title: Conventional Commits, scope is one of `domain`, `dns`, `email`, `gcp`, `github`, `ci`, `docs`. Add new scopes by editing [`commitlint.config.mjs`](commitlint.config.mjs) when this repo gets one.
- No PR exceeds ~600 changed lines without a `large-change` label and pre-approval.

## 3. Plan-before-apply, always

CI runs `terraform plan` on every PR using the production state. The reviewer reads the plan output before approving. Never apply outside of the documented manual flow — there is no auto-apply on merge until WIF lands (`docs/ADRs/0001-…` follow-up).

## 4. Sensitive data

- WHOIS contact info, billing details, and any secret material live in `terraform.tfvars` (gitignored) or in GCP Secret Manager — **never in the repo**.
- The state bucket is the authoritative store. State is sensitive: contact info, secrets, etc. live in it. Treat the bucket like a credentials vault.
- Never `terraform output -json` into a log, comment, or CI artifact unless every output is non-sensitive.

## 5. Code quality

- `terraform fmt -recursive` before commit (pre-commit hook recommended).
- `terraform validate` clean.
- Resource names in `snake_case`; module/variable/output names match the resource they describe.
- One concern per `.tf` file (`domain.tf`, `dns.tf`, `email.tf`, `apis.tf`, …) — flat structure until repetition forces a module.

## 6. Decisions

Non-trivial decisions (new external service, library swap, departure from a documented pattern) need an ADR in [`docs/ADRs/`](docs/ADRs/). Number monotonically. Mark superseded ADRs `Status: Superseded by ADR-NNNN`.

## 7. Out-of-scope discoveries

When a gap surfaces that doesn't belong in the current PR, file a high-level follow-up issue rather than expanding scope — same pattern as Cruiso's `carve-out-followup` skill. Body: scope statement + acceptance + flagged unresolved decisions, ending with `Refs #N` for the issue you were on.
