#!/bin/bash

# This test file will be executed against the 'oh-my-posh-plugins' scenario devcontainer.json test.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "zsh is installed" zsh --version
check "curl is installed" curl --version
check "oh-my-zsh is installed" [ -d "$HOME/.oh-my-zsh" ]
check "oh-my-posh is installed" oh-my-posh --version
check "oh-my-posh configuration is applied" grep "oh-my-posh init zsh --config" ~/.zshrc
check "zsh-autosuggestions plugin is installed" grep "zsh-autosuggestions" ~/.zshrc
check "zsh-syntax-highlighting plugin is installed" grep "zsh-syntax-highlighting"~/.zshrc

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults