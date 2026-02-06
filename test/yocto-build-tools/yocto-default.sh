#!/bin/bash

# This test file will be executed against the 'yocto-default' scenario devcontainer.json test.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests for default installation
echo "Testing Yocto default installation..."

# Check essential build tools
check "gcc is installed" gcc --version
check "g++ is installed" g++ --version
check "make is installed" make --version
check "python3 is installed" python3 --version
check "git is installed" git --version

# Check Python modules required by Yocto
check "python3-pip is installed" pip3 --version
check "python3-git module" python3 -c "import git"

# Check compression tools
check "gzip is installed" gzip --version
check "xz is installed" xz --version
check "zstd is installed" zstd --version

# Check locale setup
check "UTF-8 locale is configured" locale | grep "en_US.UTF-8"

echo "Default installation tests completed!"

# Report results
reportResults
