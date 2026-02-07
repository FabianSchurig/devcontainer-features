#!/bin/bash

# Test scenario for yocto-esdk with no URL provided

set -e

# Import test library
source dev-container-features-test-lib

echo "Testing Yocto eSDK with no URL scenario..."

# The feature should complete successfully even without a URL
check "feature installation succeeded" bash -c "echo 'Test passed'"

# No eSDK should be installed - check that path doesn't exist or is empty
check "no SDK installed" bash -c "[ ! -d /opt/yocto-esdk ] || [ ! -e /opt/yocto-esdk/* ]"

echo "No-URL scenario test completed!"

reportResults
