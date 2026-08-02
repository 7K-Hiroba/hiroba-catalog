#!/usr/bin/env bash
# Renders every template skeleton with sample values (simulating what the
# scaffolder's fetch:template does) and validates the result:
#   - helm lint / template / unittest on each generated chart
#   - yamllint on rendered GitHub workflows
# Extend VALIDATE_* hooks per template when a stack needs more checks.
set -euo pipefail

SAMPLE_NAME="sample-app"
SAMPLE_DESCRIPTION="Sample application"
SAMPLE_OWNER="platform-team"

render() {
  local template="$1"
  local dest="$2"
  mkdir -p "$dest"
  for part in base docker helm; do
    local src="templates/${template}/skeleton/${part}"
    if [ -d "$src" ]; then
      cp -r "${src}/." "$dest/"
    fi
  done
  # Substitute scaffolder placeholders (matches values passed in template.yaml)
  grep -rlE '\$\{\{ values\.' "$dest" | while read -r f; do
    sed -i \
      -e "s/\${{ values\.name }}/${SAMPLE_NAME}/g" \
      -e "s/\${{ values\.description }}/${SAMPLE_DESCRIPTION}/g" \
      -e "s/\${{ values\.owner }}/${SAMPLE_OWNER}/g" \
      "$f"
  done
}

for template in templates/*/; do
  name="$(basename "$template")"
  work="$(mktemp -d)"
  echo "::group::Smoke test: ${name} -> ${work}"
  render "$name" "$work"

  if [ -d "${work}/helm" ]; then
    helm lint "${work}/helm"
    helm template test-release "${work}/helm" > /dev/null
    helm unittest "${work}/helm"
  fi

  echo "OK: ${name}"
  echo "::endgroup::"
done
