# Copilot Instructions for DevContainer Features Repository

## Project Overview

This repository is a collection of custom [Dev Container Features](https://containers.dev/implementors/features/) following the [dev container Feature distribution specification](https://containers.dev/implementors/features-distribution/). Features are shareable units of dev container configuration and installation code, distributed via GitHub Container Registry (GHCR).

## Repository Structure

```
.
├── src/                          # Feature implementations
│   ├── oh-my-posh/              # oh-my-posh feature
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
│   │   └── README.md
│   └── yocto-build-tools/       # yocto-build-tools feature
│       ├── devcontainer-feature.json
│       ├── install.sh
│       └── README.md
├── test/                        # Test scenarios
│   ├── _global/
│   ├── oh-my-posh/
│   └── yocto-build-tools/
└── .github/
    └── workflows/               # CI/CD workflows
```

## Tech Stack

- **Shell Scripting**: Bash for installation scripts
- **JSON**: Feature metadata and configuration
- **Docker/DevContainers**: Container runtime and tooling
- **GitHub Actions**: CI/CD automation
- **DevContainer CLI**: Testing and validation tool

## Coding Conventions

### Feature Structure

Each feature MUST contain:
1. `devcontainer-feature.json` - Feature metadata
2. `install.sh` - Installation script
3. `README.md` - Auto-generated or manually maintained documentation

### Shell Script Best Practices

1. **Always use bash shebang**: `#!/usr/bin/env bash` (preferred for portability) or `#!/bin/bash`
2. **Use set flags for safety**:
   ```bash
   set -e  # Exit on error (note: doesn't catch errors in command substitutions by default)
   set -u  # Exit on undefined variable
   set -o pipefail  # Exit on pipe failure
   ```
   Note: When using `set -e`, be aware it doesn't affect command substitutions like `$(command)` unless you use `set -o errexit` explicitly. Test error handling in conditionals carefully.
3. **Quote variables**: Always use `"${VARIABLE}"` syntax
4. **Use meaningful variable names**: Feature options are exported as capitalized environment variables
5. **Add error handling**: Check command success and provide meaningful error messages
6. **Support multiple distributions**: Test on Debian, Ubuntu, and other base images
7. **Clean up after installation**: Remove temporary files and caches
8. **Document dependencies**: Use `installsAfter` in feature JSON for ordering

### Example Install Script Pattern

```bash
#!/bin/bash
set -e

# Feature option environment variables are automatically available
echo "Installing feature with option: ${OPTION_NAME}"

# Check for required tools
if ! command -v curl &> /dev/null; then
    echo "Error: curl is required but not installed"
    exit 1
fi

# Perform installation
# ...

# Clean up
rm -rf /tmp/downloads

echo "Feature installed successfully"
```

### Feature JSON Schema

Required fields:
- `id`: Unique identifier matching directory name
- `version`: Semantic version (e.g., "1.0.0")
- `name`: Human-readable name
- `description`: Clear description of functionality

Optional but recommended:
- `options`: Configuration options with type, default, and description
- `installsAfter`: Array of features that must install first
- `containerEnv`: Environment variables to set

Example:
```json
{
    "id": "feature-name",
    "name": "Feature Name",
    "version": "1.0.0",
    "description": "Brief description of what this feature does",
    "options": {
        "optionName": {
            "type": "string",
            "default": "default-value",
            "description": "What this option controls"
        }
    },
    "installsAfter": [
        "ghcr.io/devcontainers/features/common-utils"
    ]
}
```

## Testing Requirements

### Test Structure

Each feature MUST have tests in `test/<feature-name>/`:
- Test scenarios for different configurations
- Tests against multiple base images (Debian, Ubuntu)
- Both auto-generated and scenario-based tests

### Running Tests Locally

```bash
# Install DevContainer CLI
npm install -g @devcontainers/cli

# Test a specific feature
devcontainer features test -f <feature-name> .

# Test against specific base image
devcontainer features test --skip-scenarios -f <feature-name> -i ubuntu:latest .

# Test all features
devcontainer features test .
```

### Test Scenarios

Create test scenarios in `test/<feature-name>/*.sh` to validate:
1. Installation succeeds
2. Expected commands/tools are available
3. Configuration options work correctly
4. Feature works on different base images

## Workflow and CI/CD

### GitHub Actions Workflows

1. **test.yaml**: Runs on push/PR to validate features
   - Tests each feature against multiple base images
   - Runs scenario tests
   - Runs global scenarios

2. **release.yaml**: Publishes features to GHCR
   - Triggers on version tag or main branch
   - Auto-generates README files
   - Publishes to GitHub Container Registry

3. **validate.yml**: Additional validation checks

### Version Management

- Features use semantic versioning
- Update `version` in `devcontainer-feature.json` before release
- Tag releases follow the pattern used by the release workflow
- Each feature is versioned independently

### Publishing Process

1. Update feature's `version` in `devcontainer-feature.json`
2. Push to main branch or create tag
3. GitHub Action automatically publishes to GHCR
4. Packages default to private - must be manually set to public in GHCR settings

## Common Tasks

### Adding a New Feature

1. Create directory in `src/<feature-name>/`
2. Create `devcontainer-feature.json` with metadata
3. Create `install.sh` with installation logic
4. Create test directory `test/<feature-name>/`
5. Add test scenarios
6. Add feature to test matrix in `.github/workflows/test.yaml`
7. Test locally before committing

### Modifying an Existing Feature

1. Update the relevant files in `src/<feature-name>/`
2. Increment version in `devcontainer-feature.json` appropriately:
   - Patch: Bug fixes, no API changes
   - Minor: New features, backward compatible
   - Major: Breaking changes
3. Update tests if behavior changes
4. Run tests locally to validate changes
5. Update documentation if needed

### Debugging Installation Issues

1. Test feature in a dev container locally
2. Use `docker run -it <base-image> /bin/bash` to manually test commands
3. Check logs from failed CI runs
4. Verify dependencies are available on target distributions
5. Test with minimal base images (debian:latest, ubuntu:latest)

## File and Directory Conventions

### Avoid Creating/Modifying

- Build artifacts and temporary files
- `.git/` directory contents
- Auto-generated README files (unless explicitly maintained)
- Workflow files unless improving CI/CD

### Naming Conventions

- Feature directories: lowercase with hyphens (e.g., `oh-my-posh`)
- Feature IDs: Match directory name exactly
- Environment variables: UPPERCASE with underscores
- Options: camelCase in JSON, UPPERCASE in shell scripts

## Security and Best Practices

1. **Never commit secrets**: No API keys, tokens, or credentials
2. **Validate inputs**: Sanitize user-provided options
3. **Use HTTPS**: Download from trusted sources over HTTPS
4. **Verify checksums**: When downloading binaries, verify integrity
5. **Run as non-root when possible**: Avoid unnecessary privilege escalation
6. **Clean up credentials**: Remove temporary credentials after use
7. **Pin versions**: Use specific versions of tools when possible

## Feature-Specific Notes

### oh-my-posh Feature

- Installs oh-my-posh (prompt theme engine) with transient prompt
- Uses oh-my-zsh (zsh configuration framework) for shell configuration and plugin management
- Configurable plugins (managed by oh-my-zsh) and themes (managed by oh-my-posh)
- Requires zsh to be installed
- Uses `installsAfter` to ensure common-utils installs first

### yocto-build-tools Feature

- Installs Yocto Project build dependencies
- Version-specific installation
- Large dependency set for embedded Linux builds
- Requires significant disk space and build tools

## Documentation Standards

- README files are auto-generated by release workflow
- Use NOTES.md for additional documentation that gets merged
- Keep descriptions clear and concise
- Include usage examples in feature JSON descriptions
- Document all options with types, defaults, and descriptions

## Getting Help

- Review existing features as examples
- Check [Dev Container Features specification](https://containers.dev/implementors/features/)
- Test changes locally before committing
- Use DevContainer CLI for validation
