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

if [ ! -d "/root/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

for user in /home/*; do
    if [ ! -d "$user/.oh-my-zsh" ]; then
        sudo -u $(basename $user) sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
done

# Install required fonts using oh-my-posh font install meslo
if ! command -v oh-my-posh &> /dev/null; then
    curl -s https://ohmyposh.dev/install.sh | bash -s
    oh-my-posh font install meslo
fi

# Configure oh-my-posh with the provided default configuration
cat <<EOF > /etc/oh-my-posh-config.json
{
  "version": 2,
  "final_space": true,
  "console_title_template": "{{ .Shell }} in {{ .Folder }}",
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "newline": true,
      "segments": [
        {
          "type": "path",
          "style": "plain",
          "background": "transparent",
          "foreground": "blue",
          "template": "{{ .Path }}",
          "properties": {
            "style": "full"
          }
        },
        {
          "type": "git",
          "style": "plain",
          "foreground": "p:grey",
          "background": "transparent",
          "template": " {{ .HEAD }}{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }} <cyan>{{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}</>",
          "properties": {
            "branch_icon": "",
            "commit_icon": "@",
            "fetch_status": true
          }
        }
      ]
    },
    {
      "type": "rprompt",
      "overflow": "hidden",
      "segments": [
        {
          "type": "executiontime",
          "style": "plain",
          "foreground": "yellow",
          "background": "transparent",
          "template": "{{ .FormattedMs }}",
          "properties": {
            "threshold": 5000
          }
        }
      ]
    },
    {
      "type": "prompt",
      "alignment": "left",
      "newline": true,
      "segments": [
        {
          "type": "text",
          "style": "plain",
          "foreground_templates": [
            "{{if gt .Code 0}}red{{end}}",
            "{{if eq .Code 0}}magenta{{end}}"
          ],
          "background": "transparent",
          "template": "❯"
        }
      ]
    }
  ],
  "transient_prompt": {
    "foreground_templates": [
      "{{if gt .Code 0}}red{{end}}",
      "{{if eq .Code 0}}magenta{{end}}"
    ],
    "background": "transparent",
    "template": "❯ "
  },
  "secondary_prompt": {
    "foreground": "magenta",
    "background": "transparent",
    "template": "❯❯ "
  }
}
EOF

# Enable oh-my-posh instant prompt in ~/.zshrc for all users
for user in /home/*; do
    echo 'eval "$(oh-my-posh init zsh --config /etc/oh-my-posh-config.json)"' >> $user/.zshrc
done
echo 'eval "$(oh-my-posh init zsh --config /etc/oh-my-posh-config.json)"' >> /root/.zshrc
