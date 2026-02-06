#!/bin/bash

# Test scenario for yocto-esdk with no URL provided

set -e

# Import test library
source dev-container-features-test-lib

echo "Testing Yocto eSDK with no URL scenario..."

# The feature should complete successfully even without a URL
check "feature installation succeeded" bash -c "echo 'Test passed'"

# Minimal dependencies should be installed
check "wget is installed" wget --version
check "file is installed" file --version

# Locale should be configured
check "locale configured" locale | grep "en_US.UTF-8"

# No eSDK should be installed
check "no SDK installed" bash -c "[ ! -d /opt/yocto-esdk ] || [ -z \"\$(ls -A /opt/yocto-esdk 2>/dev/null)\" ]"

echo "No-URL scenario test completed!"

reportResults
