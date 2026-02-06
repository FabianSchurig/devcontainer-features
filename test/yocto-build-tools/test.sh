#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'yocto-build-tools' Feature with no options.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.

echo "Testing Yocto build tools installation..."

# Check essential build tools
check "gcc is installed" gcc --version
check "g++ is installed" g++ --version
check "make is installed" make --version
check "python3 is installed" python3 --version
check "git is installed" git --version
check "wget is installed" wget --version

# Check Python modules required by Yocto
check "python3-pip is installed" pip3 --version
check "python3-git module" python3 -c "import git"
check "python3-jinja2 module" python3 -c "import jinja2"

# Check compression tools
check "gzip is installed" gzip --version
check "bzip2 is installed" bzip2 --version
check "xz is installed" xz --version
check "zstd is installed" zstd --version

# Check other required utilities
check "diffstat is installed" diffstat -V
check "chrpath is installed" chrpath --version
check "socat is installed" socat -V
check "cpio is installed" cpio --version
check "file is installed" file --version

# Check locale setup
check "UTF-8 locale is configured" locale | grep "en_US.UTF-8"

# Check info file exists
check "yocto-info.txt exists" test -f /usr/local/share/yocto-info.txt

echo "Basic Yocto build tools tests completed!"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
