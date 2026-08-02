# ${{ values.name }}

${{ values.description }}

Next.js application scaffolded from the `nextjs-app` Hiroba template.

## Development

```bash
npm ci
npm run dev
```

## Build

```bash
npm run build
npm start
```

## CI/CD

- Pull requests: PR title lint, Docker build + Trivy scan, Helm chart validation
- Releases: release-please on `main`; publishing a GitHub release builds and pushes
  the container image and Helm chart to Harbor (signed with cosign)

All workflows use [7K-Group/workflows-library](https://github.com/7K-Group/workflows-library) `@v1`.
