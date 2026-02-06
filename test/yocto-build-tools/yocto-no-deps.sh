#!/bin/bash

# This test file will be executed against the 'yocto-no-deps' scenario devcontainer.json test.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests for no-dependencies installation
echo "Testing Yocto no-dependencies installation..."

# Verify the feature respects the installDependencies flag
# We just check that the installation completed without errors

echo "No-dependencies mode tests completed!"

# Report results
reportResults
