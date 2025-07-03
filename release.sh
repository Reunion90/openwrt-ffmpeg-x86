#!/bin/bash

# Release Management Script for OpenWrt FFmpeg
# This script helps create and manage releases

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to create a new release
create_release() {
    local version="$1"
    local description="$2"
    
    if [ -z "$version" ]; then
        print_error "Version is required"
        echo "Usage: $0 create <version> [description]"
        echo "Example: $0 create v1.0.0 'First stable release'"
        exit 1
    fi
    
    # Add 'v' prefix if not present
    if [[ ! "$version" =~ ^v ]]; then
        version="v$version"
    fi
    
    print_step "Creating release $version"
    
    # Check if tag already exists
    if git tag -l | grep -q "^$version$"; then
        print_error "Tag $version already exists"
        exit 1
    fi
    
    # Set default description if not provided
    if [ -z "$description" ]; then
        description="FFmpeg $version for OpenWrt 24.10 x86_64 with H.264 support"
    fi
    
    print_info "Version: $version"
    print_info "Description: $description"
    
    # Create and push tag
    print_step "Creating git tag..."
    git tag -a "$version" -m "$description"
    
    print_step "Pushing tag to GitHub..."
    git push origin "$version"
    
    print_info "✅ Release $version created successfully!"
    print_info "🚀 GitHub Actions will now build packages and create the release"
    print_info "📦 Packages will be automatically attached to the release"
    print_info "🔗 Check progress at: https://github.com/Reunion90/openwrt-ffmpeg-x86/actions"
}

# Function to list existing releases
list_releases() {
    print_step "Existing releases:"
    
    if git tag -l | grep -q "^v"; then
        git tag -l | grep "^v" | sort -V | while read tag; do
            local date=$(git log -1 --format=%ai "$tag" 2>/dev/null | cut -d' ' -f1)
            echo "  📦 $tag ($date)"
        done
    else
        print_warning "No releases found"
        print_info "Create your first release with: $0 create v1.0.0"
    fi
}

# Function to delete a release
delete_release() {
    local version="$1"
    
    if [ -z "$version" ]; then
        print_error "Version is required"
        echo "Usage: $0 delete <version>"
        exit 1
    fi
    
    # Add 'v' prefix if not present
    if [[ ! "$version" =~ ^v ]]; then
        version="v$version"
    fi
    
    print_warning "⚠️  This will delete release $version"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "Deleting local tag..."
        git tag -d "$version" 2>/dev/null || true
        
        print_step "Deleting remote tag..."
        git push origin ":refs/tags/$version" 2>/dev/null || true
        
        print_info "✅ Release $version deleted"
        print_warning "Note: You may need to manually delete the GitHub release page"
    else
        print_info "Cancelled"
    fi
}

# Function to show release status
release_status() {
    print_step "Release Status"
    
    echo "📍 Repository: https://github.com/Reunion90/openwrt-ffmpeg-x86"
    echo "🔄 Actions: https://github.com/Reunion90/openwrt-ffmpeg-x86/actions"
    echo "📦 Releases: https://github.com/Reunion90/openwrt-ffmpeg-x86/releases"
    echo ""
    
    # Check latest commit
    local latest_commit=$(git rev-parse --short HEAD)
    local commit_msg=$(git log -1 --format=%s)
    echo "🔖 Latest commit: $latest_commit - $commit_msg"
    
    # Check if there are unpushed changes
    if ! git diff-index --quiet HEAD --; then
        print_warning "⚠️  You have uncommitted changes"
        echo "   Run 'git status' to see changes"
    fi
    
    # Check if local is ahead of remote
    local ahead=$(git rev-list --count HEAD ^origin/main 2>/dev/null || echo "0")
    if [ "$ahead" -gt 0 ]; then
        print_warning "⚠️  You have $ahead unpushed commits"
        echo "   Run 'git push' to sync with GitHub"
    fi
    
    echo ""
    list_releases
}

# Function to show help
show_help() {
    echo "OpenWrt FFmpeg Release Management"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  create <version> [description]  Create a new release"
    echo "  list                           List existing releases"
    echo "  delete <version>               Delete a release"
    echo "  status                         Show release status"
    echo "  help                           Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 create v1.0.0                    # Create v1.0.0 with default description"
    echo "  $0 create 1.1.0 'Bug fixes'         # Create v1.1.0 with custom description"
    echo "  $0 create v2.0.0-beta 'Beta test'   # Create beta release"
    echo "  $0 list                              # Show all releases"
    echo "  $0 delete v1.0.0                    # Delete release v1.0.0"
    echo "  $0 status                            # Show current status"
    echo ""
    echo "Version Examples:"
    echo "  v1.0.0      - Stable release"
    echo "  v1.1.0      - Minor update"
    echo "  v2.0.0      - Major update"
    echo "  v1.0.0-rc1  - Release candidate"
    echo "  v1.0.0-beta - Beta version"
    echo ""
    echo "What happens when you create a release:"
    echo "  1. 🏷️  Git tag is created locally"
    echo "  2. 📤 Tag is pushed to GitHub"
    echo "  3. 🤖 GitHub Actions starts building"
    echo "  4. 📦 IPK packages are compiled"
    echo "  5. 🎉 Release is created with packages attached"
    echo ""
    echo "Repository: https://github.com/Reunion90/openwrt-ffmpeg-x86"
}

# Main script
main() {
    case "${1:-help}" in
        create)
            create_release "$2" "$3"
            ;;
        list)
            list_releases
            ;;
        delete)
            delete_release "$2"
            ;;
        status)
            release_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
