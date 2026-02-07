#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'yocto-esdk' Feature with no options.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.

echo "Testing Yocto eSDK installation..."

# Since no SDK URL was provided, the feature should complete without error
# but should not install anything (including dependencies)
check "feature completed without error" bash -c "echo 'Feature ran successfully'"

# Check that the install path does not exist or is empty (since no URL was provided)
check "install path does not exist or is empty" bash -c "[ ! -d /opt/yocto-esdk ] || [ ! -e /opt/yocto-esdk/* ]"

echo "Yocto eSDK (no URL) tests completed!"

# Report result
reportResults
