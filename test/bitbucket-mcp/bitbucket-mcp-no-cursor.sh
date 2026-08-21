#!/bin/bash

# Scenario: configureCursor disabled. The credentials file is still seeded so the
# VS Code registration keeps working, but Cursor's config is left alone.

set -e

source dev-container-features-test-lib

# shellcheck source=/dev/null
source /usr/local/share/bitbucket-mcp/config.env

check "configureCursor is recorded as false" bash -c "[ '$CONFIGURE_CURSOR' = 'false' ]"
check "cursor config was not created" bash -c "! test -e '$CURSOR_FILE'"
check "credentials file is still seeded" test -f "$ENV_FILE"
check "credentials file is mode 600" bash -c "[ \"\$(stat -c '%a' '$ENV_FILE')\" = '600' ]"

reportResults
