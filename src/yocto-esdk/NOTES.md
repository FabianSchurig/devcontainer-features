# Yocto Extensible SDK (eSDK)

## Overview

This feature automates the installation of the Yocto Extensible SDK (eSDK) in your devcontainer. The eSDK provides a complete development environment including BitBake, the build engine, and a sysroot tailored to your specific image.

## Features

- **Minimal footprint**: Only installs essential dependencies (wget, file, locales)
- **Silent installation**: Uses `-y -d <path>` flags for unattended setup
- **Multi-repo support**: Compatible with various distributions (Artifactory, HTTP server, etc.)
- **Auto-configuration**: Automatically sources SDK environment for all users
- **Flexible**: Optional auto-sourcing and configurable installation path

## Usage

### Basic Usage

```json
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/FabianSchurig/devcontainer-features/yocto-esdk:1": {
            "sdkUrl": "https://example.com/path/to/esdk-installer.sh"
        }
    }
}
```

### Advanced Configuration

```json
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/FabianSchurig/devcontainer-features/yocto-esdk:1": {
            "sdkUrl": "https://artifactory.example.com/yocto/esdk/installer.sh",
            "installPath": "/workspace/yocto-sdk",
            "autoSourceEnvironment": false
        }
    }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `sdkUrl` | string | `""` | URL to the Yocto eSDK self-extracting installer script. Leave empty to skip installation. |
| `installPath` | string | `"/opt/yocto-esdk"` | Path where the eSDK should be installed |
| `autoSourceEnvironment` | boolean | `true` | Automatically source the eSDK environment setup script for all users |

## How it Works

1. **Minimal Dependencies**: Installs only wget, file, and locales packages
2. **Download**: Fetches the eSDK installer from the provided URL
3. **Silent Installation**: Runs the installer with `-y -d <path>` flags for unattended setup
4. **Environment Setup**: Creates a profile.d script to automatically source the SDK environment (if enabled)

## Manual Environment Sourcing

If you set `autoSourceEnvironment: false`, you can manually source the environment:

```bash
source /opt/yocto-esdk/environment-setup-*
```

## Requirements

- The eSDK installer must be a self-extracting shell script
- The installer should support `-y` (yes to prompts) and `-d` (directory) flags
- Internet connectivity to download the installer

## Notes

- If no `sdkUrl` is provided, the feature will exit gracefully without installing anything
- The feature is designed to work with standard Yocto eSDK installers that follow the expected structure
- Locale is set to `en_US.UTF-8` for compatibility with Yocto builds
