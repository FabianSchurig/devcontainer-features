# oh-my-posh

A feature to install oh-my-posh with transient prompt using oh-my-zsh

## Example Usage

```json
"features": {
    "ghcr.io/devcontainers/feature-starter/oh-my-posh:1": {
        "plugins": "git,debian,docker,sudo,vscode,poetry,postgres,cp",
        "theme": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/powerlevel10k_rainbow.omp.json"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| plugins | Space separated list of additional zsh plugins to configure | string | git debian docker sudo vscode poetry postgres cp |
| theme | The theme to use for oh-my-posh | string | https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/powerlevel10k_rainbow.omp.json |

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/devcontainers/feature-starter/blob/main/src/oh-my-posh/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
