#!/bin/bash

# This test file will be executed against the 'yocto-kirkstone' scenario devcontainer.json test.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests for kirkstone version
echo "Testing Yocto kirkstone version installation..."

# Check essential build tools
check "gcc is installed" gcc --version
check "python3 is installed" python3 --version
check "git is installed" git --version

# Check Python modules
check "python3-pip is installed" pip3 --version
check "python3-git module" python3 -c "import git"

# Check info file contains kirkstone version
check "yocto-info.txt exists" test -f /usr/local/share/yocto-info.txt
check "yocto-info.txt contains kirkstone version" grep "kirkstone" /usr/local/share/yocto-info.txt

echo "Kirkstone version tests completed!"

# Report results
reportResults
