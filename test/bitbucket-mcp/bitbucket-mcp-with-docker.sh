#!/bin/bash

# Scenario: the feature alongside a Docker CLI, which is what a real user needs
# for the MCP server to actually start.
#
# docker-outside-of-docker is installed with "moby": false so the scenario
# still runs on floating Ubuntu tags (currently "resolute") where the default
# moby-cli packages are not available.

set -e

source dev-container-features-test-lib

# shellcheck source=/dev/null
source /usr/local/share/bitbucket-mcp/config.env

check "docker CLI is available for the MCP server" command -v docker
check "credentials file exists" test -f "$ENV_FILE"
check "cursor config registers the pinned image" \
    bash -c "[ \"\$(jq -r '.mcpServers[\"$MCP_SERVER_NAME\"].args[-1]' '$CURSOR_FILE')\" = '$MCP_IMAGE' ]"
check "the registered command is a docker stdio server" \
    bash -c "[ \"\$(jq -r '.mcpServers[\"$MCP_SERVER_NAME\"].type' '$CURSOR_FILE')\" = 'stdio' ]"
check "the env file the server reads is the one that was seeded" \
    bash -c "[ \"\$(jq -r '.mcpServers[\"$MCP_SERVER_NAME\"].args[4]' '$CURSOR_FILE')\" = '\${userHome}/.config/bitbucket-mcp.env' ]"

reportResults
