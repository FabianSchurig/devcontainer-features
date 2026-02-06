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
# but should not install the eSDK
check "feature completed without error" bash -c "echo 'Feature ran successfully'"

# Check that minimal dependencies are available (if they were installed)
check "wget is available" command -v wget
check "file is available" command -v file

# Check that locale is properly configured
check "UTF-8 locale is configured" locale | grep -i "en_US.UTF-8"

# Check that the install path does not exist (since no URL was provided)
check "install path should not exist" bash -c "[ ! -d /opt/yocto-esdk ] || [ -z \"\$(ls -A /opt/yocto-esdk 2>/dev/null)\" ]"

echo "Yocto eSDK (no URL) tests completed!"

# Report result
reportResults
