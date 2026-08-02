# AGENTS.md

Conventions for working on this repository. Read before adding or modifying templates.

## Repository purpose

This repo holds Backstage software templates (`scaffolder.backstage.io/v1beta3`) used by
Hiroba to scaffold new projects into the `7K-Hiroba` GitHub org.

## Template anatomy (mandatory)

```
templates/<name>/
├── template.yaml            # Template entity: parameters, steps, output
└── skeleton/
    ├── base/                # always fetched (fetch:template, step has no `if`)
    ├── docker/              # fetched only when parameters.includeDocker
    └── helm/                # fetched only when parameters.includeHelm
```

- Every template exposes `includeDocker` and `includeHelm` boolean parameters (default
  `true`), enforced via `if: ${{ parameters.includeDocker }}` on the fetch steps.
- Steps: `fetch:template` (base) → `fetch:template` (docker, conditional) →
  `fetch:template` (helm, conditional) → `publish:github` → `catalog:register`.
- Publishing runs as the logged-in user, not the Backstage GitHub App: `repoUrl` uses
  `requestUserCredentials.secretsKey: USER_OAUTH_TOKEN` (scopes `repo`, `workflow`) and
  `publish:github` receives `token: ${{ secrets.USER_OAUTH_TOKEN }}`. Requires the
  GitHub auth provider in Hiroba and repo-creation rights in `7K-Hiroba` for the user.

## The `${{ }}` conflict (critical)

`fetch:template` renders every fetched file with Nunjucks. Two file families contain
literal `{{ }}` that must NOT be rendered:

1. **GitHub workflow files** (`${{ github... }}`) — always listed in
   `copyWithoutRender: ['./.github/**']`. Workflows must therefore never need scaffolder
   values: use `${{ github.repository }}` / `${{ github.event.repository.name }}` for
   image names.
2. **Helm chart templates** (`{{ .Values.x }}`) — always listed in
   `copyWithoutRender: ['./helm/templates/**']` on the helm fetch step. Only
   `Chart.yaml` / `values.yaml` may use `${{ values.* }}` placeholders.

## Generated-repo CI/CD standards

- All reusable workflow calls go to `7K-Group/workflows-library` pinned `@v1`, with
  `secrets: inherit` where secrets are needed.
- `ci-app.yml` wants a FULL image ref (e.g. `ghcr.io/<org>/<repo>` — lowercase!);
  `release-app.yml` wants the SHORT name (`${{ github.event.repository.name }}`).
- Release jobs trigger on `release: [published]` (release-please creates the GitHub
  release) and strip the leading `v` from the tag for the `version` input.
- Helm charts MUST include `values.schema.json` and at least one helm-unittest file
  under `helm/tests/` — `ci-helm.yml` fails without them.
- Generated repos use release-please with `include-component-in-tag: false` so tags are
  plain `vX.Y.Z`.

## Version policy

Templates pin the latest stable major of each toolchain (currently: Node 24 LTS
`node:24-alpine`, Go 1.26 `golang:1.26-alpine`, Next.js 16, React 19). Generated repos
stay current via Renovate. Refresh these pins when they drift.

## Validation

- Run `./hack/smoke-test.sh` after changing any skeleton (requires helm + helm-unittest
  plugin). CI runs it on every PR.
- PR titles must be Conventional Commits (`feat`, `fix`, `docs`, `style`, `refactor`,
  `perf`, `test`, `build`, `ci`, `chore`, `revert`).
- Do not commit rendered sample output; skeletons keep their `${{ values.* }}`
  placeholders.
