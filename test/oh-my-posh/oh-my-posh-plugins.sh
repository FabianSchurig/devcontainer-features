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
for user_home in /home/*; do
    if [ -d "$user_home" ]; then
        cat "$user_home/.zshrc"
        check "oh-my-posh configuration is applied for $user_home" grep "eval \"\$(oh-my-posh init zsh --config \$HOME/oh-my-posh-config.json)\"" "$user_home/.zshrc"
        check "zsh-autosuggestions plugin is installed for $user_home" grep "zsh-autosuggestions" "$user_home/.zshrc"
        check "zsh-syntax-highlighting plugin is installed for $user_home" grep "zsh-syntax-highlighting" "$user_home/.zshrc"
        check "oh-my-posh-config.json is similar to the remote file for $user_home" diff "$user_home/oh-my-posh-config.json" <(curl -s https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/pure.omp.json)
    fi
done

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults