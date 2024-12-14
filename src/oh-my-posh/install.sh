#!/bin/bash
set -e

# Install zsh, curl, oh-my-zsh, and oh-my-posh for all users in /home/* and /root if not already installed.
if ! command -v zsh &> /dev/null; then
  apt-get update
  apt-get install -y zsh
fi

if ! command -v curl &> /dev/null; then
  apt-get install -y curl
fi

if ! command -v git &> /dev/null; then
  apt-get install -y git
fi

# Install oh-my-zsh for /root and each user in /home/*
for user in /root /home/*; do
  if [ ! -d "$user/.oh-my-zsh" ]; then
    runuser -l $(basename $user) -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
done

# Install oh-my-posh for root
if ! command -v oh-my-posh &> /dev/null; then
  curl -s https://ohmyposh.dev/install.sh | bash -s
  bash -c 'source ~/.profile && oh-my-posh font install meslo'
fi

# Fetch the oh-my-posh configuration file from the provided URL and copy it to /etc/skel
THEME=${theme:-https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/powerlevel10k_rainbow.omp.json}
curl -fsSL $THEME -o /etc/skel/oh-my-posh-config.json

# Copy the oh-my-posh configuration file to each user's home directory and enable oh-my-posh instant prompt in ~/.zshrc
for user in /root /home/*; do
  cp /etc/skel/oh-my-posh-config.json $user/
  chown $(basename $user):$(basename $user) $user/oh-my-posh-config.json
  chmod 644 $user/oh-my-posh-config.json
  runuser -l $(basename $user) -c 'echo "source ~/.profile && eval \"$(oh-my-posh init zsh --config $HOME/oh-my-posh-config.json)\"" >> $HOME/.zshrc'
done

# Install additional plugins for each user and /root
PLUGINS=${plugins:-"git debian docker sudo vscode poetry postgres cp"}
for user in /root /home/*; do
  runuser -l $(basename $user) -c "sed -i '/^plugins=/ s/)/ $PLUGINS)/' \$HOME/.zshrc"
done
