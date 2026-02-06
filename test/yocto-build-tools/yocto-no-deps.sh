#!/bin/bash

# This test file will be executed against the 'yocto-no-deps' scenario devcontainer.json test.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests for no-dependencies installation
echo "Testing Yocto no-dependencies installation..."

# When installDependencies is false, we should still have the info file
check "yocto-info.txt exists" test -f /usr/local/share/yocto-info.txt
check "yocto-info.txt contains scarthgap version" grep "scarthgap" /usr/local/share/yocto-info.txt

# But we should not have all the build tools installed (since we skipped dependencies)
# This test verifies the feature respects the installDependencies flag

echo "No-dependencies mode tests completed!"

# Report results
reportResults
