#!/bin/bash
set -e

echo "Activating feature 'yocto-esdk'"

# Get options from environment variables (converted by devcontainer spec)
SDK_URL=${SDKURL:-""}
INSTALL_PATH=${INSTALLPATH:-"/opt/yocto-esdk"}
AUTO_SOURCE=${AUTOSOURCEENVIRONMENT:-"true"}

echo "SDK URL: ${SDK_URL}"
echo "Install path: ${INSTALL_PATH}"
echo "Auto-source environment: ${AUTO_SOURCE}"

# Function to install minimal dependencies for eSDK
install_minimal_dependencies() {
    echo "Installing minimal dependencies for eSDK..."
    
    # Update package lists
    export DEBIAN_FRONTEND=noninteractive
    
    # Check if apt-get is available (Debian/Ubuntu)
    if command -v apt-get &> /dev/null; then
        apt-get update
        
        # Only install essential packages needed for eSDK installation
        # wget: to download the installer
        # file: often needed by SDK installers
        # locales: required for proper locale setup
        apt-get install -y wget file locales
        
        # Set up locale (required for SDK)
        if ! grep -q "en_US.UTF-8 UTF-8" /etc/locale.gen 2>/dev/null; then
            echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
        fi
        
        # Generate locale
        locale-gen en_US.UTF-8 2>/dev/null || true
        update-locale LANG=en_US.UTF-8 2>/dev/null || true
        
        echo "Minimal dependencies installed."
    else
        echo "Warning: apt-get not found. Assuming dependencies are already available."
    fi
}

# Function to install eSDK from URL
install_esdk() {
    local url=$1
    local install_path=$2
    
    echo "Installing Yocto eSDK from ${url}..."
    
    # Create installation directory
    mkdir -p "${install_path}"
    
    # Download the eSDK installer
    local temp_installer="/tmp/yocto-esdk-installer.sh"
    echo "Downloading eSDK installer..."
    wget -O "${temp_installer}" "${url}"
    
    # Make it executable
    chmod +x "${temp_installer}"
    
    # Run the installer in silent mode
    # -y: accept defaults/yes to prompts
    # -d: specify installation directory
    echo "Running eSDK installer (silent mode)..."
    "${temp_installer}" -y -d "${install_path}"
    
    # Clean up the installer
    rm -f "${temp_installer}"
    
    echo "eSDK installed successfully at ${install_path}"
}

# Function to setup environment for eSDK
setup_esdk_environment() {
    local install_path=$1
    local auto_source=$2
    
    if [ "${auto_source}" != "true" ]; then
        echo "Auto-source disabled. Users will need to manually source the environment setup script."
        return
    fi
    
    echo "Setting up eSDK environment..."
    
    # Find the environment setup script
    local env_script=""
    if [ -f "${install_path}/environment-setup-"* ]; then
        env_script=$(find "${install_path}" -maxdepth 1 -name "environment-setup-*" -type f | head -n 1)
    fi
    
    if [ -z "${env_script}" ]; then
        echo "Warning: Could not find environment-setup script in ${install_path}"
        echo "The eSDK may not have installed correctly, or the structure is different than expected."
        return
    fi
    
    echo "Found environment setup script: ${env_script}"
    
    # Create a profile.d script to automatically source the eSDK environment
    cat > /etc/profile.d/yocto-esdk.sh << EOF
# Yocto eSDK environment setup
# Automatically source the SDK environment for interactive shells
if [ -f "${env_script}" ]; then
    . "${env_script}"
fi
EOF
    
    chmod 644 /etc/profile.d/yocto-esdk.sh
    
    echo "Environment setup script created at /etc/profile.d/yocto-esdk.sh"
    echo "The eSDK environment will be automatically sourced for all users."
}

# Main installation logic
if [ -z "${SDK_URL}" ]; then
    echo "No SDK URL provided. Skipping eSDK installation."
    echo "To use this feature, provide the 'sdkUrl' option pointing to your eSDK installer."
    echo ""
    echo "Example:"
    echo '  "features": {'
    echo '    "ghcr.io/FabianSchurig/devcontainer-features/yocto-esdk:1": {'
    echo '      "sdkUrl": "https://example.com/path/to/esdk-installer.sh"'
    echo '    }'
    echo '  }'
    exit 0
fi

# Install minimal dependencies
install_minimal_dependencies

# Install eSDK
install_esdk "${SDK_URL}" "${INSTALL_PATH}"

# Setup environment
setup_esdk_environment "${INSTALL_PATH}" "${AUTO_SOURCE}"

echo "Yocto eSDK feature installation completed successfully!"
echo ""
echo "To use the SDK, either:"
echo "  1. Start a new shell (if autoSourceEnvironment is true)"
echo "  2. Manually source: . ${INSTALL_PATH}/environment-setup-*"
