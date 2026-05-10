# InnoVestrum Infrastructure

Infrastructure-as-Code for InnoVestrum org-level resources. Terraform on Google Cloud, single state file in `gs://innovestrum-tf-state`.

## Scope

What lives here:

- **Domain + DNS** — `innovestrum.com` via Cloud Domains, hosted on Cloud DNS.
- **Email forwarding** — Forward Email free tier records (`*@innovestrum.com` → maintainer inbox).
- **Shared GCP foundations** — `innovestrum` GCP project, project-level IAM, future Workload Identity Federation.
- **GitHub org config** — teams, labels, repo settings (added when the need is recurring; one-off changes stay in the UI).

What does **not** live here:

- Per-product infrastructure (Cruiso's GCP resources live in the `cruiso` GCP project, managed in [`innovestrum/cruiso`](https://github.com/innovestrum/cruiso) under #29 when WIF lands).
- Application code or CI/CD for products.

## Quickstart for maintainers

```bash
# One-time
gcloud auth login
gcloud auth application-default login
gcloud config set project innovestrum

# Per change
cd terraform/
cp terraform.tfvars.example terraform.tfvars   # edit with real contact info
terraform init
terraform plan
terraform apply
```

`terraform.tfvars` is gitignored. The state bucket holds the only authoritative copy of contact info — never commit a populated `*.tfvars` file.

## State

- Backend: GCS, `gs://innovestrum-tf-state`, EU region, versioned, uniform IAM.
- Locking: GCS object locks (built into the `gcs` backend).
- No workspaces — single environment.

## Contributing

- Branch model + commit style mirror [`innovestrum/cruiso/AGENTS.md` §4](https://github.com/innovestrum/cruiso/blob/main/AGENTS.md).
- Every PR runs `terraform fmt -check`, `terraform validate`, and `terraform plan` against the live backend. Apply is manual, by a maintainer with `roles/owner` on the `innovestrum` project.
- ADRs for non-trivial decisions live in [`docs/ADRs/`](docs/ADRs/).

## Cost

| Item | Yearly |
|---|---|
| `innovestrum.com` registration + renewal | $12 |
| Cloud DNS managed zone | ~$2.40 |
| State bucket storage | ~$0 |
| **Total** | **~$15** |

Plus future Workspace ($72/yr per user) when SMTP-send is needed.
