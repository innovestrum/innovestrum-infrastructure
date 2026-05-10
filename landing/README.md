# landing/

Single-file `index.html` for `innovestrum.com` while the real product is being built. HTML + inline CSS, no build step.

## Where it's served

**Temporarily** parked on the `dhcloud` VM (`free-tier-instance` in the `dhcloud-dev` GCP project) — a personal host that already runs Caddy with auto-TLS. The dhcloud Caddy image fetches this file from `raw.githubusercontent.com/innovestrum/innovestrum-infrastructure/main/landing/index.html` at image build time; redeploying that container picks up the latest committed version.

Migration off this temporary parking is tracked in the spillover issue (see [#3](https://github.com/innovestrum/innovestrum-infrastructure/issues/3)).

## Editing

Edit `index.html`, open a PR. After merge, rebuild the dhcloud container image to refresh the served copy:

```bash
gcloud builds submit \
  --project=dhcloud-dev \
  --tag=us-central1-docker.pkg.dev/dhcloud-dev/dhcloud-dev/dhcloud-dev-frontend:latest \
  /path/to/dhcloud/frontend
```

Then recreate the container on the VM (`gcloud compute ssh free-tier-instance --zone=us-central1-a --project=dhcloud-dev` → re-run the docker run command, or reset the instance to re-run its startup script).
