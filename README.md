# hiroba-catalog

Backstage software templates for scaffolding new 7K-Hiroba projects. Registered in
Hiroba via the root [`catalog-info.yaml`](catalog-info.yaml) `Location`, which points at
every `templates/*/template.yaml`.

## Templates

| Template | Description |
|---|---|
| [`nextjs-app`](templates/nextjs-app) | Next.js landing page / web app (TypeScript, App Router) |
| [`go-service`](templates/go-service) | Go microservice (stdlib HTTP, `/healthz`, graceful shutdown) |

## What every generated project gets

- Baseline folder structure and minimal runnable application code
- Latest stable language/toolchain versions, kept current afterwards by Renovate
- `renovate.json` (org-shared Renovate app config)
- release-please (`release-please-config.json` + `.release-please-manifest.json`)
- `catalog-info.yaml` registered back into Hiroba
- Optional, toggleable in the scaffolder form:
  - **Dockerfile** — multi-stage, non-root, plus CI (`ci-app`) and release (`release-app`) workflows
  - **Helm chart** — `helm/`, plus CI (`ci-helm`) and release (`release-helm`) workflows

All CI/CD calls the reusable workflows in
[`7K-Group/workflows-library`](https://github.com/7K-Group/workflows-library) pinned to `@v1`.

## Generated repo workflow layout

| File | Comes from | Purpose |
|---|---|---|
| `.github/workflows/ci.yml` | base skeleton | PR title lint (+ Go build/vet/test/govulncheck for `go-service`) |
| `.github/workflows/release-please.yml` | base skeleton | release-please version management on `main` |
| `.github/workflows/docker-ci.yml` | docker skeleton | Docker build + Trivy scan via `ci-app.yml` |
| `.github/workflows/docker-release.yml` | docker skeleton | On GitHub release: build/push/sign image to Harbor via `release-app.yml` |
| `.github/workflows/helm-ci.yml` | helm skeleton | Chart lint/template/unittest/ct/kubeconform via `ci-helm.yml` |
| `.github/workflows/helm-release.yml` | helm skeleton | On GitHub release: push OCI chart to Harbor via `release-helm.yml` |

Because each optional piece contributes its own workflow files, disabling Docker or Helm
in the scaffolder form yields a repo with matching CI — no dead jobs.

## Required org secrets (7K-Hiroba)

Release workflows use `secrets: inherit` and expect these at the org level:

- `HARBOR_REGISTRY`, `HARBOR_PROJECT`, `HARBOR_ROBOT_NAME`, `HARBOR_ROBOT_TOKEN`
- Optional: `RELEASE_PLEASE_TOKEN` (PAT so release PRs trigger CI; falls back to `GITHUB_TOKEN`)

## Authentication during scaffolding

Templates publish with the **logged-in user's GitHub credentials**, not the Backstage
GitHub App: the `repoUrl` field requests a user OAuth grant (`repo` + `workflow`
scopes) and `publish:github` uses that token. This requires:

- the GitHub auth provider configured in Hiroba (`auth.providers.github`), and
- the user to have permission to create repositories in the `7K-Hiroba` org.

## Adding a new template

1. Copy an existing template directory and adjust `template.yaml` + `skeleton/`.
2. Keep the skeleton split: `base/` (always), `docker/` and `helm/` (conditionally fetched).
3. Register the template in `catalog-info.yaml` (Location targets).
4. Extend `hack/smoke-test.sh` validation if the stack needs more than Helm checks.
5. See [`AGENTS.md`](AGENTS.md) for the full conventions checklist.

## Local validation

```bash
./hack/smoke-test.sh   # renders all skeletons with sample values, helm lint/template/unittest
```
