#!/bin/bash
set -e

echo "Activating feature 'yocto-build-tools'"

# Get options from environment variables
YOCTO_VERSION=${VERSION:-"scarthgap"}
BUILDTOOLS_URL=${BUILDTOOLSURL:-""}
BUILDTOOLS_PATH=${BUILDTOOLSPATH:-"/opt/yocto-buildtools"}
INSTALL_DEPENDENCIES=${INSTALLDEPENDENCIES:-"true"}

echo "Yocto version: ${YOCTO_VERSION}"
echo "Install dependencies: ${INSTALL_DEPENDENCIES}"
echo "Buildtools URL: ${BUILDTOOLS_URL}"
echo "Buildtools path: ${BUILDTOOLS_PATH}"

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    DISTRO_VERSION=$VERSION_ID
    echo "Detected distribution: ${DISTRO} ${DISTRO_VERSION}"
else
    echo "Warning: Could not detect distribution. Assuming Ubuntu/Debian."
    DISTRO="ubuntu"
fi

# Function to install packages based on distribution
install_yocto_dependencies() {
    echo "Installing Yocto build dependencies..."
    
    # Update package lists
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    
    # Essential packages required for Yocto builds (based on Yocto documentation)
    # Reference: https://docs.yoctoproject.org/ref-manual/system-requirements.html
    
    case "${DISTRO}" in
        ubuntu|debian)
            echo "Installing dependencies for Ubuntu/Debian..."
            
            # Core build tools and utilities
            apt-get install -y \
                gawk \
                wget \
                git \
                diffstat \
                unzip \
                texinfo \
                gcc \
                build-essential \
                chrpath \
                socat \
                cpio \
                python3 \
                python3-pip \
                python3-pexpect \
                xz-utils \
                debianutils \
                iputils-ping \
                python3-git \
                python3-jinja2 \
                python3-subunit \
                zstd \
                lz4 \
                file \
                locales \
                libacl1
            
            # Additional recommended packages
            apt-get install -y \
                make \
                g++ \
                gcc-multilib \
                lz4 \
                tar \
                bzip2 \
                gzip \
                patch \
                perl \
                sed \
                findutils \
                diffutils \
                which \
                xterm \
                libncurses5-dev \
                libncursesw5-dev \
                libtinfo-dev \
                libssl-dev \
                vim \
                curl || true
            
            echo "Dependencies installed successfully."
            ;;
        *)
            echo "Warning: Unsupported distribution '${DISTRO}'. Attempting to install basic dependencies..."
            apt-get install -y \
                gawk wget git diffstat unzip texinfo gcc build-essential \
                chrpath socat cpio python3 python3-pip xz-utils debianutils \
                iputils-ping file locales || true
            ;;
    esac
    
    # Set up locale (required for Yocto builds)
    if ! grep -q "en_US.UTF-8 UTF-8" /etc/locale.gen; then
        echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    fi
    
    # Generate locale without LC_ALL set
    unset LC_ALL
    locale-gen en_US.UTF-8
    
    # Update locale configuration (ignore errors on minimal systems)
    update-locale LANG=en_US.UTF-8 2>/dev/null || true
    
    # Set locale environment variables for all shells
    cat > /etc/profile.d/yocto-locale.sh << 'EOF'
# Set locale for Yocto builds
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
EOF
    chmod 755 /etc/profile.d/yocto-locale.sh
    
    # Export for current shell and container environment
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
}

# Function to install buildtools from URL
install_buildtools() {
    local url=$1
    local install_path=$2
    
    echo "Installing Yocto buildtools from ${url}..."
    
    # Create installation directory
    mkdir -p "${install_path}"
    
    # Download buildtools
    local temp_file="/tmp/yocto-buildtools.sh"
    echo "Downloading buildtools..."
    wget -O "${temp_file}" "${url}"
    
    # Make it executable
    chmod +x "${temp_file}"
    
    # Run the installer
    echo "Running buildtools installer..."
    "${temp_file}" -d "${install_path}" -y
    
    # Clean up
    rm -f "${temp_file}"
    
    # Create environment setup script for all users
    cat > /etc/profile.d/yocto-buildtools.sh << EOF
# Yocto buildtools environment setup
if [ -f "${install_path}/environment-setup-x86_64-pokysdk-linux" ]; then
    source "${install_path}/environment-setup-x86_64-pokysdk-linux"
elif [ -d "${install_path}" ]; then
    # Look for any environment-setup script
    SETUP_SCRIPT=\$(find "${install_path}" -name "environment-setup-*" -type f | head -n 1)
    if [ -n "\${SETUP_SCRIPT}" ]; then
        source "\${SETUP_SCRIPT}"
    fi
fi
EOF
    
    chmod 644 /etc/profile.d/yocto-buildtools.sh
    
    echo "Buildtools installed successfully at ${install_path}"
}

# Main installation logic
if [ "${INSTALL_DEPENDENCIES}" = "true" ]; then
    install_yocto_dependencies
else
    echo "Skipping dependency installation (INSTALL_DEPENDENCIES=false)"
fi

# Install buildtools if URL is provided
if [ -n "${BUILDTOOLS_URL}" ]; then
    install_buildtools "${BUILDTOOLS_URL}" "${BUILDTOOLS_PATH}"
else
    echo "No buildtools URL provided. Skipping buildtools installation."
    echo "You can manually clone Poky or use the feature with buildtoolsUrl option."
fi

# Create a helpful info file
cat > /usr/local/share/yocto-info.txt << EOF
Yocto Build Tools Feature
==========================

Version: ${YOCTO_VERSION}
Installation Date: $(date)

This container has been configured with Yocto Project build dependencies.

Next steps:
1. Clone Poky repository:
   git clone -b ${YOCTO_VERSION} git://git.yoctoproject.org/poky.git
   
2. Initialize build environment:
   cd poky
   source oe-init-build-env

3. Start building:
   bitbake core-image-minimal

For more information, visit:
https://docs.yoctoproject.org/

EOF

echo "Yocto Build Tools feature installation completed successfully!"
echo "See /usr/local/share/yocto-info.txt for next steps."
