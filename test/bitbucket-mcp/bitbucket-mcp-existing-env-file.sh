#!/bin/bash

# Scenario: credentials forwarded through remoteEnv. The feature should write
# them into the env file verbatim, without quoting, since docker --env-file
# treats quotes as part of the value.

set -e

source dev-container-features-test-lib

# shellcheck source=/dev/null
source /usr/local/share/bitbucket-mcp/config.env

check "credentials file exists" test -f "$ENV_FILE"
check "username written unquoted" \
    bash -c "grep -qx 'BITBUCKET_USERNAME=someone@example.com' '$ENV_FILE'"
check "token written unquoted" \
    bash -c "grep -qx 'BITBUCKET_TOKEN=token-from-the-environment' '$ENV_FILE'"
check "no template placeholders were left behind" \
    bash -c "! grep -q 'your-api-token' '$ENV_FILE'"
check "credentials file is mode 600" bash -c "[ \"\$(stat -c '%a' '$ENV_FILE')\" = '600' ]"

reportResults
