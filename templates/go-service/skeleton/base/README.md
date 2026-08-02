# ${{ values.name }}

${{ values.description }}

Go microservice scaffolded from the `go-service` Hiroba template.

## Development

```bash
make run    # go run ./cmd/server
make test   # go test -race ./...
make build  # go build -o bin/server ./cmd/server
```

## Endpoints

- `GET /` — service info
- `GET /healthz` — health check

Configuration via environment: `PORT` (default `8080`).

## CI/CD

- Pull requests: PR title lint, `go build/vet/test` + govulncheck, Docker build + Trivy scan, Helm chart validation
- Releases: release-please on `main`; publishing a GitHub release builds and pushes
  the container image and Helm chart to Harbor (signed with cosign)

All workflows use [7K-Group/workflows-library](https://github.com/7K-Group/workflows-library) `@v1`.
