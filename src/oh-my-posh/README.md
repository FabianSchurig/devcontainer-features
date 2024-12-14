# oh-my-posh

A feature to install oh-my-posh with transient prompt using oh-my-zsh

## Example Usage

```json
"features": {
    "ghcr.io/devcontainers/feature-starter/oh-my-posh:1": {
        "additionalPlugins": "zsh-autosuggestions,zsh-syntax-highlighting"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| additionalPlugins | Comma-separated list of additional zsh plugins to install | string |  |

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/devcontainers/feature-starter/blob/main/src/oh-my-posh/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
