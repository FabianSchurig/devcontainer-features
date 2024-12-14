#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'oh-my-posh' Feature with no options.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "zsh is installed" zsh --version
check "curl is installed" curl --version
check "oh-my-zsh is installed" [ -d "$HOME/.oh-my-zsh" ]
check "oh-my-posh is installed" oh-my-posh --version
check "oh-my-posh configuration is applied" grep 'eval "$(oh-my-posh init zsh --config /etc/oh-my-posh-config.json)"' $HOME/.zshrc

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
