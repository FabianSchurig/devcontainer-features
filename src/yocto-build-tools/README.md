
# Yocto Build Tools (yocto-build-tools)

Installs Yocto Project build tools and dependencies for building embedded Linux distributions

## Example Usage

### Basic Usage

Install Yocto build dependencies with default settings:

```json
"features": {
    "ghcr.io/FabianSchurig/devcontainer-features/yocto-build-tools:1": {}
}
```

### With Buildtools Installation

Install Yocto buildtools from a URL (useful for older host distributions):

```json
"features": {
    "ghcr.io/FabianSchurig/devcontainer-features/yocto-build-tools:1": {
        "buildtoolsUrl": "http://downloads.yoctoproject.org/releases/yocto/yocto-5.0/buildtools/x86_64-buildtools-extended-nativesdk-standalone-5.0.sh",
        "buildtoolsPath": "/opt/yocto-buildtools"
    }
}
```

### Skip Dependencies Installation

Install only the feature configuration without dependencies (useful if dependencies are already installed):

```json
"features": {
    "ghcr.io/FabianSchurig/devcontainer-features/yocto-build-tools:1": {
        "installDependencies": false
    }
}
```

## Getting Started with Yocto

After the feature is installed, you can start using Yocto:

1. Clone the Poky repository:
```bash
git clone -b scarthgap git://git.yoctoproject.org/poky.git
cd poky
```

2. Initialize the build environment:
```bash
source oe-init-build-env
```

3. Build a basic image:
```bash
bitbake core-image-minimal
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| buildtoolsUrl | Optional URL to download and install Yocto buildtools tarball (e.g., buildtools-extended tarball for specific host distributions) | string | - |
| buildtoolsPath | Path where buildtools should be installed if buildtoolsUrl is provided | string | /opt/yocto-buildtools |
| installDependencies | Install required build dependencies for Yocto (based on distribution) | boolean | true |

## System Requirements

This feature installs the following essential packages for Yocto builds:

- Build tools: gcc, g++, make, build-essential
- Python 3 and required modules (pip, pexpect, git, jinja2, subunit)
- Compression tools: gzip, bzip2, xz-utils, zstd, lz4
- Utilities: git, wget, curl, diffstat, chrpath, socat, cpio
- Development libraries: libssl-dev, libncurses5-dev

Based on the [Yocto Project System Requirements](https://docs.yoctoproject.org/ref-manual/system-requirements.html).

## Supported Distributions

- Ubuntu (all recent versions)
- Debian (all recent versions)

## Notes

- The feature automatically configures UTF-8 locale required for Yocto builds
- If buildtoolsUrl is provided, the buildtools environment is automatically sourced via /etc/profile.d/

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/FabianSchurig/devcontainer-features/blob/main/src/yocto-build-tools/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
