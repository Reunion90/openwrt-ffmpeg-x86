#!/bin/bash

# Build script for FFmpeg OpenWrt packages
# This script automates the build process for local development

set -e

# Configuration
OPENWRT_VERSION="24.10.0"
OPENWRT_TARGET="x86-64"
SDK_URL="https://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/x86/64/openwrt-sdk-${OPENWRT_VERSION}-x86-64_gcc-13.3.0_musl.Linux-x86_64.tar.xz"
WORKSPACE_DIR="$(pwd)"
BUILD_DIR="/tmp/openwrt-build"
SDK_DIR="${BUILD_DIR}/openwrt-sdk"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on supported system
check_system() {
    print_status "Checking system requirements..."
    
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        print_error "This script requires Linux. Use WSL on Windows or a Linux VM."
        exit 1
    fi
    
    # Check for required tools
    local required_tools="wget tar make gcc"
    for tool in $required_tools; do
        if ! command -v $tool &> /dev/null; then
            print_error "Required tool '$tool' is not installed."
            exit 1
        fi
    done
    
    print_status "System check passed."
}

# Install build dependencies
install_dependencies() {
    print_status "Installing build dependencies..."
    
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y \
            build-essential \
            clang \
            flex \
            bison \
            g++ \
            gawk \
            gcc-multilib \
            g++-multilib \
            gettext \
            git \
            libncurses5-dev \
            libssl-dev \
            python3-distutils \
            rsync \
            unzip \
            zlib1g-dev \
            file \
            wget \
            subversion
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y \
            gcc \
            gcc-c++ \
            clang \
            flex \
            bison \
            gawk \
            gettext \
            git \
            ncurses-devel \
            openssl-devel \
            python3 \
            rsync \
            unzip \
            zlib-devel \
            file \
            wget \
            subversion
    else
        print_warning "Package manager not detected. Please install dependencies manually."
    fi
    
    print_status "Dependencies installed."
}

# Download and extract OpenWrt SDK
setup_sdk() {
    print_status "Setting up OpenWrt SDK..."
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    if [ ! -f "openwrt-sdk.tar.xz" ]; then
        print_status "Downloading OpenWrt SDK..."
        wget -O openwrt-sdk.tar.xz "$SDK_URL"
    else
        print_status "Using cached SDK archive."
    fi
    
    if [ -d "$SDK_DIR" ]; then
        print_status "Removing existing SDK directory..."
        rm -rf "$SDK_DIR"
    fi
    
    print_status "Extracting SDK..."
    tar -xf openwrt-sdk.tar.xz
    mv openwrt-sdk-* "$SDK_DIR"
    
    print_status "SDK setup complete."
}

# Copy package files to SDK
copy_package_files() {
    print_status "Copying package files to SDK..."
    
    local package_dir="${SDK_DIR}/package/multimedia/ffmpeg"
    mkdir -p "$package_dir"
    
    cp -r "${WORKSPACE_DIR}/package/"* "$package_dir/"
    
    print_status "Package files copied."
}

# Update feeds and configure build
configure_build() {
    print_status "Updating feeds and configuring build..."
    
    cd "$SDK_DIR"
    
    print_status "Updating feeds..."
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    
    print_status "Configuring build..."
    make defconfig
    
    # Enable FFmpeg packages
    echo "CONFIG_PACKAGE_ffmpeg=y" >> .config
    echo "CONFIG_PACKAGE_ffprobe=y" >> .config
    echo "CONFIG_PACKAGE_libffmpeg-full=y" >> .config
    echo "CONFIG_FFMPEG_ENCODER_LIBX264=y" >> .config
    echo "CONFIG_FFMPEG_DECODER_H264=y" >> .config
    
    make defconfig
    
    print_status "Build configured."
}

# Build the packages
build_packages() {
    print_status "Building FFmpeg packages..."
    
    cd "$SDK_DIR"
    
    # Build with verbose output and parallel jobs
    local cpu_count=$(nproc)
    print_status "Building with $cpu_count parallel jobs..."
    
    if make package/multimedia/ffmpeg/compile V=s -j"$cpu_count"; then
        print_status "Build completed successfully!"
    else
        print_error "Build failed. Check the output above for errors."
        exit 1
    fi
}

# Collect and organize build artifacts
collect_artifacts() {
    print_status "Collecting build artifacts..."
    
    cd "$SDK_DIR"
    
    local artifacts_dir="${WORKSPACE_DIR}/artifacts"
    mkdir -p "$artifacts_dir"
    
    # Find and copy all relevant packages
    find bin/packages -name "*.ipk" -path "*/multimedia/*" -exec cp {} "$artifacts_dir/" \;
    find bin/packages -name "*ffmpeg*" -exec cp {} "$artifacts_dir/" \;
    find bin/packages -name "*x264*" -exec cp {} "$artifacts_dir/" \;
    
    print_status "Artifacts collected in: $artifacts_dir"
    ls -la "$artifacts_dir"
}

# Clean up build directory
cleanup() {
    if [ "$1" = "--clean" ]; then
        print_status "Cleaning up build directory..."
        rm -rf "$BUILD_DIR"
        print_status "Cleanup complete."
    else
        print_status "Build directory preserved: $BUILD_DIR"
        print_status "Use '$0 --clean' to clean up."
    fi
}

# Print usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Build FFmpeg packages for OpenWrt x86_64"
    echo
    echo "OPTIONS:"
    echo "  --deps-only     Install dependencies only"
    echo "  --no-deps       Skip dependency installation"
    echo "  --clean         Clean up build directory after build"
    echo "  --help          Show this help message"
    echo
    echo "Examples:"
    echo "  $0              # Full build process"
    echo "  $0 --no-deps    # Build without installing dependencies"
    echo "  $0 --clean      # Build and clean up afterwards"
}

# Main execution
main() {
    local skip_deps=false
    local deps_only=false
    local clean_after=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --deps-only)
                deps_only=true
                shift
                ;;
            --no-deps)
                skip_deps=true
                shift
                ;;
            --clean)
                clean_after=true
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    print_status "Starting FFmpeg build for OpenWrt..."
    
    check_system
    
    if [ "$deps_only" = true ]; then
        install_dependencies
        print_status "Dependencies installed. Run without --deps-only to build."
        exit 0
    fi
    
    if [ "$skip_deps" = false ]; then
        install_dependencies
    fi
    
    setup_sdk
    copy_package_files
    configure_build
    build_packages
    collect_artifacts
    
    if [ "$clean_after" = true ]; then
        cleanup --clean
    else
        cleanup
    fi
    
    print_status "Build process completed successfully!"
    print_status "Package files are available in: ${WORKSPACE_DIR}/artifacts"
}

# Run main function with all arguments
main "$@"
