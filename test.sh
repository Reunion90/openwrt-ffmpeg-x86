#!/bin/bash

# Test script for FFmpeg OpenWrt packages
# This script helps verify that the built packages work correctly

set -e

# Configuration
ARTIFACTS_DIR="artifacts"
TEST_DIR="/tmp/ffmpeg-test"
SAMPLE_VIDEO_URL="https://sample-videos.com/zip/10/mp4/SampleVideo_720x480_1mb.mp4"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[TEST]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if artifacts exist
check_artifacts() {
    print_status "Checking for build artifacts..."
    
    if [ ! -d "$ARTIFACTS_DIR" ]; then
        print_error "Artifacts directory not found. Run build.sh first."
        exit 1
    fi
    
    local ipk_count=$(find "$ARTIFACTS_DIR" -name "*.ipk" | wc -l)
    if [ "$ipk_count" -eq 0 ]; then
        print_error "No IPK packages found in artifacts directory."
        exit 1
    fi
    
    print_status "Found $ipk_count IPK packages."
    ls -la "$ARTIFACTS_DIR"/*.ipk
}

# Verify package contents
verify_packages() {
    print_status "Verifying package contents..."
    
    cd "$ARTIFACTS_DIR"
    
    for ipk in *.ipk; do
        print_status "Examining package: $ipk"
        
        # Extract package info
        ar t "$ipk" | head -5
        
        # Check if it's a valid OpenWrt package
        if ar t "$ipk" | grep -q "control.tar.gz"; then
            print_status "✓ Valid OpenWrt package format"
        else
            print_warning "⚠ Unusual package format for $ipk"
        fi
    done
}

# Test package installation (requires OpenWrt environment)
test_installation() {
    print_status "Testing package installation..."
    
    if ! command -v opkg &> /dev/null; then
        print_warning "opkg not found. Skipping installation test."
        print_warning "This test should be run on an OpenWrt device."
        return
    fi
    
    cd "$ARTIFACTS_DIR"
    
    # Install packages in dependency order
    local packages=("libffmpeg-full" "ffmpeg" "ffprobe")
    
    for pkg in "${packages[@]}"; do
        local ipk_file=$(ls ${pkg}_*.ipk 2>/dev/null | head -1)
        if [ -n "$ipk_file" ]; then
            print_status "Installing $ipk_file..."
            if opkg install "$ipk_file"; then
                print_status "✓ Successfully installed $pkg"
            else
                print_error "✗ Failed to install $pkg"
            fi
        fi
    done
}

# Test FFmpeg functionality
test_ffmpeg() {
    print_status "Testing FFmpeg functionality..."
    
    if ! command -v ffmpeg &> /dev/null; then
        print_warning "ffmpeg not found in PATH. Skipping functionality test."
        return
    fi
    
    # Test version and codec support
    print_status "FFmpeg version information:"
    ffmpeg -version | head -5
    
    print_status "Available encoders (H.264):"
    ffmpeg -encoders 2>/dev/null | grep -i h264 || print_warning "No H.264 encoders found"
    
    print_status "Available decoders (H.264):"
    ffmpeg -decoders 2>/dev/null | grep -i h264 || print_warning "No H.264 decoders found"
    
    print_status "libx264 encoder:"
    ffmpeg -h encoder=libx264 2>/dev/null | head -5 || print_warning "libx264 encoder not available"
}

# Test FFprobe functionality
test_ffprobe() {
    print_status "Testing FFprobe functionality..."
    
    if ! command -v ffprobe &> /dev/null; then
        print_warning "ffprobe not found in PATH. Skipping functionality test."
        return
    fi
    
    print_status "FFprobe version information:"
    ffprobe -version | head -3
}

# Create a test video and verify encoding
test_encoding() {
    print_status "Testing H.264 encoding..."
    
    if ! command -v ffmpeg &> /dev/null; then
        print_warning "ffmpeg not available. Skipping encoding test."
        return
    fi
    
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Create a simple test video
    print_status "Creating test video..."
    if ffmpeg -f lavfi -i testsrc=duration=5:size=320x240:rate=1 -y test_input.mp4 &>/dev/null; then
        print_status "✓ Test input video created"
    else
        print_warning "Failed to create test input video"
        return
    fi
    
    # Test H.264 encoding
    print_status "Testing H.264 encoding with libx264..."
    if ffmpeg -i test_input.mp4 -c:v libx264 -preset ultrafast -crf 23 -y test_output.mp4 &>/dev/null; then
        print_status "✓ H.264 encoding successful"
        
        # Verify the output
        if [ -f "test_output.mp4" ] && [ -s "test_output.mp4" ]; then
            local file_size=$(stat -c%s "test_output.mp4" 2>/dev/null || echo "unknown")
            print_status "✓ Output file created (size: $file_size bytes)"
        else
            print_warning "Output file is empty or missing"
        fi
    else
        print_error "✗ H.264 encoding failed"
    fi
    
    # Test FFprobe on the encoded file
    if [ -f "test_output.mp4" ] && command -v ffprobe &> /dev/null; then
        print_status "Testing FFprobe on encoded file..."
        if ffprobe -v quiet -print_format json -show_format -show_streams test_output.mp4 &>/dev/null; then
            print_status "✓ FFprobe analysis successful"
        else
            print_warning "FFprobe analysis failed"
        fi
    fi
    
    # Cleanup
    rm -f test_input.mp4 test_output.mp4
}

# Cleanup test environment
cleanup() {
    if [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
        print_status "Test directory cleaned up"
    fi
}

# Main test function
main() {
    print_status "Starting FFmpeg package tests..."
    
    check_artifacts
    verify_packages
    test_installation
    test_ffmpeg
    test_ffprobe
    test_encoding
    
    cleanup
    
    print_status "All tests completed!"
    print_status "If you're on an OpenWrt device, the packages should be ready to use."
}

# Print usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Test FFmpeg packages built for OpenWrt"
    echo
    echo "OPTIONS:"
    echo "  --help          Show this help message"
    echo
    echo "Examples:"
    echo "  $0              # Run all tests"
}

# Handle command line arguments
if [ "$1" = "--help" ]; then
    usage
    exit 0
fi

# Run tests
main "$@"
