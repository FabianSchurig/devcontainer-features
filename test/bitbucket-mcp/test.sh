#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'bitbucket-mcp' Feature with no options.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

SHARE_DIR="/usr/local/share/bitbucket-mcp"
CONFIG_FILE="${SHARE_DIR}/config.env"
POST_CREATE="${SHARE_DIR}/post-create.sh"

check "config.env was written" test -f "$CONFIG_FILE"
check "post-create.sh is executable" test -x "$POST_CREATE"

# shellcheck source=/dev/null
source "$CONFIG_FILE"

# postCreateCommand runs as the remote user; these tests may run as root.
# Extra arguments are passed through `env`, so callers can inject variables.
run_post_create() {
    if [ "$(id -un)" = "$TARGET_USER" ]; then
        env "$@" "$POST_CREATE"
    elif command -v runuser >/dev/null 2>&1; then
        runuser -u "$TARGET_USER" -- env "$@" "$POST_CREATE"
    elif [ "$#" -gt 0 ]; then
        # `su -c` cannot pass argv, so extra env is applied as the current user.
        env "$@" "$POST_CREATE"
    else
        su -s /bin/bash "$TARGET_USER" -c "$POST_CREATE"
    fi
}

restore_owner() {
    if [ "$(id -u)" = "0" ] && [ "$TARGET_USER" != "root" ]; then
        chown "$TARGET_USER" "$1"
    fi
}

# --- credentials file -------------------------------------------------------

check "credentials file exists" test -f "$ENV_FILE"
check "credentials file is mode 600" \
    bash -c "[ \"\$(stat -c '%a' '$ENV_FILE')\" = '600' ]"
check "credentials file is owned by the remote user" \
    bash -c "[ \"\$(stat -c '%U' '$ENV_FILE')\" = '$TARGET_USER' ]"
check "credentials template has no active values" \
    bash -c "! grep -qE '^[A-Z]' '$ENV_FILE'"

# --- Cursor registration ----------------------------------------------------

check "jq is available for the merge" command -v jq
check "cursor config exists" test -f "$CURSOR_FILE"
check "cursor config is valid JSON" jq -e . "$CURSOR_FILE"
check "server is registered under mcpServers" \
    bash -c "[ \"\$(jq -r '.mcpServers[\"$MCP_SERVER_NAME\"].command' '$CURSOR_FILE')\" = 'docker' ]"
check "server uses the pinned image" \
    bash -c "[ \"\$(jq -r '.mcpServers[\"$MCP_SERVER_NAME\"].args[-1]' '$CURSOR_FILE')\" = '$MCP_IMAGE' ]"
check "userHome placeholder is left literal for Cursor to resolve" \
    bash -c "jq -e '.mcpServers[\"$MCP_SERVER_NAME\"].args | index(\"\${userHome}/.config/bitbucket-mcp.env\")' '$CURSOR_FILE'"

# --- the merge must never destroy an existing config ------------------------

jq '.mcpServers.unrelated = {"command": "npx", "args": ["-y", "other-mcp"]} | .keepMe = "yes"' \
    "$CURSOR_FILE" > /tmp/bbmcp-merged.json
cat /tmp/bbmcp-merged.json > "$CURSOR_FILE"
restore_owner "$CURSOR_FILE"
run_post_create

check "an unrelated server survives the merge" \
    bash -c "[ \"\$(jq -r '.mcpServers.unrelated.command' '$CURSOR_FILE')\" = 'npx' ]"
check "an unrelated top-level key survives the merge" \
    bash -c "[ \"\$(jq -r '.keepMe' '$CURSOR_FILE')\" = 'yes' ]"
check "our server is still registered after the merge" \
    bash -c "[ \"\$(jq -r '.mcpServers[\"$MCP_SERVER_NAME\"].command' '$CURSOR_FILE')\" = 'docker' ]"
check "config is still valid JSON after the merge" jq -e . "$CURSOR_FILE"

# --- a stale entry is refreshed to the pinned image -------------------------

jq '.mcpServers["'"$MCP_SERVER_NAME"'"].args = ["run", "stale"]' \
    "$CURSOR_FILE" > /tmp/bbmcp-stale.json
cat /tmp/bbmcp-stale.json > "$CURSOR_FILE"
restore_owner "$CURSOR_FILE"
run_post_create

check "a stale entry is replaced with the pinned image" \
    bash -c "[ \"\$(jq -r '.mcpServers[\"$MCP_SERVER_NAME\"].args[-1]' '$CURSOR_FILE')\" = '$MCP_IMAGE' ]"
check "the previous config was backed up" test -f "${CURSOR_FILE}.bak"
check "the unrelated server survived the refresh" \
    bash -c "[ \"\$(jq -r '.mcpServers.unrelated.command' '$CURSOR_FILE')\" = 'npx' ]"

# --- re-running changes nothing ---------------------------------------------

BEFORE="$(sha256sum "$CURSOR_FILE" | cut -d' ' -f1)"
ENV_BEFORE="$(sha256sum "$ENV_FILE" | cut -d' ' -f1)"
run_post_create
check "a repeat run leaves the cursor config byte-identical" \
    bash -c "[ \"\$(sha256sum '$CURSOR_FILE' | cut -d' ' -f1)\" = '$BEFORE' ]"
check "a repeat run leaves the credentials file byte-identical" \
    bash -c "[ \"\$(sha256sum '$ENV_FILE' | cut -d' ' -f1)\" = '$ENV_BEFORE' ]"

# --- credentials with a newline fall back to the template -------------------

rm -f "$ENV_FILE"
run_post_create \
    BITBUCKET_USERNAME='someone@example.com' \
    BITBUCKET_TOKEN=$'tok\nenv-injection=1'

check "a token with a newline does not get written" \
    bash -c "! grep -q 'tok' '$ENV_FILE'"
check "a newline in the token does not inject extra env-file records" \
    bash -c "! grep -q 'env-injection' '$ENV_FILE'"
check "the commented template is written instead" \
    bash -c "grep -q 'your-api-token' '$ENV_FILE'"

# --- a malformed config is never clobbered ----------------------------------

echo '{ not json' > "$CURSOR_FILE"
restore_owner "$CURSOR_FILE"
run_post_create
check "a malformed cursor config is left untouched" \
    bash -c "[ \"\$(cat '$CURSOR_FILE')\" = '{ not json' ]"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
