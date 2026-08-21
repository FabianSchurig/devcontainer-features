#!/usr/bin/env bash
# The bitbucket-mcp image tag is declared twice: once in devcontainer-feature.json
# for VS Code, which reads customizations.vscode.mcp directly, and once in
# install.sh for Cursor, which gets the same server written into ~/.cursor/mcp.json.
# Feature option values are never substituted into customizations, so the tag
# cannot be shared through an option. This guards the duplication instead.
set -euo pipefail

FEATURE_DIR="src/bitbucket-mcp"
PATTERN='ghcr\.io/fabianschurig/bitbucket-mcp:[0-9][^"]*'

extract() {
    local file="$1" tag
    tag="$(grep -oE "$PATTERN" "$file" | sort -u)"
    if [ -z "$tag" ]; then
        echo "No image reference found in ${file}" >&2
        exit 1
    fi
    if [ "$(printf '%s\n' "$tag" | wc -l)" -ne 1 ]; then
        echo "Conflicting image references inside ${file}:" >&2
        printf '  %s\n' "$tag" >&2
        exit 1
    fi
    printf '%s' "$tag"
}

json_tag="$(extract "${FEATURE_DIR}/devcontainer-feature.json")"
install_tag="$(extract "${FEATURE_DIR}/install.sh")"

if [ "$json_tag" != "$install_tag" ]; then
    cat >&2 <<EOF
Image tag mismatch between the VS Code and Cursor registrations:
  devcontainer-feature.json: ${json_tag}
  install.sh:                ${install_tag}
Bump both, and the feature version along with them.
EOF
    exit 1
fi

echo "bitbucket-mcp image tag is consistent: ${json_tag}"
