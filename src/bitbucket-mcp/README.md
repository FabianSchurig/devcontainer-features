
# Bitbucket MCP Server (bitbucket-mcp)

Registers the bb-mcp Bitbucket MCP server for VS Code and Cursor, and seeds its credentials file

## Example Usage

```json
"features": {
    "ghcr.io/FabianSchurig/devcontainer-features/bitbucket-mcp:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| configureCursor | Also register the server in ~/.cursor/mcp.json for Cursor, which does not read customizations.vscode.mcp | boolean | true |


## What this feature does

It does not install anything Bitbucket-specific into your container. It registers the published `bb-mcp` image as an MCP server and makes sure the credentials file the server reads exists, so that both GitHub Copilot and Cursor can talk to Bitbucket from inside the dev container.

Two things happen:

1. **VS Code** picks up the server from this feature's `customizations.vscode.mcp` metadata and merges it into the container's `mcp.json` (VS Code 1.102 and later).
2. **Cursor** does not read that metadata, so `postCreateCommand` writes the same server definition into `~/.cursor/mcp.json` under `mcpServers`. Set `configureCursor` to `false` to skip this.

The server itself is the pinned `ghcr.io/fabianschurig/bitbucket-mcp` image, run with `docker run --rm -i`. The tag is pinned in the feature rather than exposed as an option, so the exact image is visible to anyone reading the feature. Upgrading means bumping the feature version.

## Requirements

The MCP server runs `docker` from inside the container, so a Docker CLI has to be present. This feature deliberately does **not** pull one in automatically, because doing so would conflict for anyone already using `docker-in-docker` and a feature conflict fails container creation. Add whichever you prefer:

```json
"features": {
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {},
    "ghcr.io/FabianSchurig/devcontainer-features/bitbucket-mcp:1": {}
}
```

If Docker is missing the container still comes up normally and `postCreate` prints a warning naming both options.

## Credentials

The server reads `~/.config/bitbucket-mcp.env` inside the container. The feature creates that file during `postCreateCommand` if it is not already there, with mode `600`. Pick whichever of the three ways below suits you.

### Forward them from your host environment

Nothing to create by hand. The feature writes the file from these variables when both are set:

```json
"remoteEnv": {
    "BITBUCKET_USERNAME": "${localEnv:BITBUCKET_USERNAME}",
    "BITBUCKET_TOKEN": "${localEnv:BITBUCKET_TOKEN}"
}
```

### Bind-mount a file you keep on the host

If you already keep credentials at `~/.config/bitbucket-mcp.env` on your machine, mount it in. The feature detects the existing file and leaves it completely alone.

```json
"initializeCommand": "mkdir -p \"${localEnv:HOME}/.config\" && touch \"${localEnv:HOME}/.config/bitbucket-mcp.env\"",
"mounts": [
    "source=${localEnv:HOME}/.config/bitbucket-mcp.env,target=/home/vscode/.config/bitbucket-mcp.env,type=bind,readonly"
]
```

The `initializeCommand` is not optional here: a bind mount whose source does not exist fails container creation outright. A feature cannot run anything on the host, which is why this stays in your `devcontainer.json`. Also make sure the mount target matches your image's remote user, which is `vscode` on the common base images but `codespace` in GitHub Codespaces and `node` on the JavaScript images.

### Edit the file in the container

Open the template the feature left at `~/.config/bitbucket-mcp.env` and uncomment the two lines.

> Do not quote the values. `docker --env-file` passes them through verbatim, so quotes end up as part of the token and produce `401 Unauthorized`.

Create an Atlassian scoped API token as described in the [bb-mcp usage guide](https://github.com/FabianSchurig/bitbucket-cli/blob/main/docs/mcp.md).

## Verifying it works

- **VS Code**: `F1` then `MCP: List Servers`, and look for `bitbucket-mcp-server`.
- **Cursor**: Settings, then Tools & Integrations, where the server should show a green status dot.

If the server fails to start, the usual causes are a missing Docker CLI and an empty credentials file. Both are reported in the `postCreate` output.

## Notes on the Cursor config

`~/.cursor/mcp.json` is merged rather than overwritten. An existing file keeps all of its other servers and keys; only the `bitbucket-mcp-server` entry is added or refreshed, and the previous file is copied to `mcp.json.bak` before any change to an existing entry. If the file is not valid JSON it is left untouched and the snippet to add is printed instead.

Only the global config is touched. Cursor also reads a project-level `.cursor/mcp.json` which takes priority on a name clash, so you can always override this in your repository.

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/FabianSchurig/devcontainer-features/blob/main/src/bitbucket-mcp/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
