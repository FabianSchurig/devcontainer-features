
# Yocto Build Tools (yocto-build-tools)

Installs Yocto Project build tools and dependencies for building embedded Linux distributions

## Example Usage

```json
"features": {
    "ghcr.io/FabianSchurig/devcontainer-features/yocto-build-tools:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| buildtoolsUrl | Optional URL to download and install Yocto buildtools tarball (e.g., buildtools-extended tarball for specific host distributions) | string | - |
| buildtoolsPath | Path where buildtools should be installed if buildtoolsUrl is provided | string | /opt/yocto-buildtools |
| installDependencies | Install required build dependencies for Yocto (based on distribution) | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/FabianSchurig/devcontainer-features/blob/main/src/yocto-build-tools/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
