# Release Management Script for OpenWrt FFmpeg (PowerShell)
# This script helps create and manage releases on Windows

param(
    [Parameter(Position=0)]
    [string]$Command = "help",
    
    [Parameter(Position=1)]
    [string]$Version,
    
    [Parameter(Position=2)]
    [string]$Description
)

# Colors for output
function Write-Info($message) {
    Write-Host "[INFO] $message" -ForegroundColor Green
}

function Write-Step($message) {
    Write-Host "[STEP] $message" -ForegroundColor Blue
}

function Write-Warning($message) {
    Write-Host "[WARN] $message" -ForegroundColor Yellow
}

function Write-Error($message) {
    Write-Host "[ERROR] $message" -ForegroundColor Red
}

# Function to create a new release
function New-Release {
    param($version, $description)
    
    if (-not $version) {
        Write-Error "Version is required"
        Write-Host "Usage: .\release.ps1 create <version> [description]"
        Write-Host "Example: .\release.ps1 create v1.0.0 'First stable release'"
        exit 1
    }
    
    # Add 'v' prefix if not present
    if (-not $version.StartsWith('v')) {
        $version = "v$version"
    }
    
    Write-Step "Creating release $version"
    
    # Check if tag already exists
    $existingTags = git tag -l | Where-Object { $_ -eq $version }
    if ($existingTags) {
        Write-Error "Tag $version already exists"
        exit 1
    }
    
    # Set default description if not provided
    if (-not $description) {
        $description = "FFmpeg $version for OpenWrt 24.10 x86_64 with H.264 support"
    }
    
    Write-Info "Version: $version"
    Write-Info "Description: $description"
    
    # Create and push tag
    Write-Step "Creating git tag..."
    git tag -a $version -m $description
    
    Write-Step "Pushing tag to GitHub..."
    git push origin $version
    
    Write-Info "✅ Release $version created successfully!"
    Write-Info "🚀 GitHub Actions will now build packages and create the release"
    Write-Info "📦 Packages will be automatically attached to the release"
    Write-Info "🔗 Check progress at: https://github.com/Reunion90/openwrt-ffmpeg-x86/actions"
}

# Function to list existing releases
function Get-Releases {
    Write-Step "Existing releases:"
    
    $tags = git tag -l | Where-Object { $_.StartsWith('v') } | Sort-Object
    
    if ($tags) {
        foreach ($tag in $tags) {
            $date = git log -1 --format=%ai $tag 2>$null
            if ($date) {
                $dateOnly = $date.Split(' ')[0]
                Write-Host "  📦 $tag ($dateOnly)"
            } else {
                Write-Host "  📦 $tag"
            }
        }
    } else {
        Write-Warning "No releases found"
        Write-Info "Create your first release with: .\release.ps1 create v1.0.0"
    }
}

# Function to delete a release
function Remove-Release {
    param($version)
    
    if (-not $version) {
        Write-Error "Version is required"
        Write-Host "Usage: .\release.ps1 delete <version>"
        exit 1
    }
    
    # Add 'v' prefix if not present
    if (-not $version.StartsWith('v')) {
        $version = "v$version"
    }
    
    Write-Warning "⚠️  This will delete release $version"
    $confirm = Read-Host "Are you sure? (y/N)"
    
    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        Write-Step "Deleting local tag..."
        git tag -d $version 2>$null
        
        Write-Step "Deleting remote tag..."
        git push origin ":refs/tags/$version" 2>$null
        
        Write-Info "✅ Release $version deleted"
        Write-Warning "Note: You may need to manually delete the GitHub release page"
    } else {
        Write-Info "Cancelled"
    }
}

# Function to show release status
function Get-ReleaseStatus {
    Write-Step "Release Status"
    
    Write-Host "📍 Repository: https://github.com/Reunion90/openwrt-ffmpeg-x86"
    Write-Host "🔄 Actions: https://github.com/Reunion90/openwrt-ffmpeg-x86/actions"
    Write-Host "📦 Releases: https://github.com/Reunion90/openwrt-ffmpeg-x86/releases"
    Write-Host ""
    
    # Check latest commit
    $latestCommit = git rev-parse --short HEAD
    $commitMsg = git log -1 --format=%s
    Write-Host "🔖 Latest commit: $latestCommit - $commitMsg"
    
    # Check if there are unpushed changes
    $hasChanges = git diff-index --quiet HEAD
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "⚠️  You have uncommitted changes"
        Write-Host "   Run 'git status' to see changes"
    }
    
    # Check if local is ahead of remote
    try {
        $ahead = git rev-list --count HEAD ^origin/main 2>$null
        if ($ahead -and [int]$ahead -gt 0) {
            Write-Warning "⚠️  You have $ahead unpushed commits"
            Write-Host "   Run 'git push' to sync with GitHub"
        }
    } catch {
        # Ignore errors for rev-list
    }
    
    Write-Host ""
    Get-Releases
}

# Function to show help
function Show-Help {
    Write-Host "OpenWrt FFmpeg Release Management (PowerShell)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\release.ps1 <command> [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  create <version> [description]  Create a new release"
    Write-Host "  list                           List existing releases"
    Write-Host "  delete <version>               Delete a release"
    Write-Host "  status                         Show release status"
    Write-Host "  help                           Show this help"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\release.ps1 create v1.0.0                    # Create v1.0.0 with default description"
    Write-Host "  .\release.ps1 create 1.1.0 'Bug fixes'         # Create v1.1.0 with custom description"
    Write-Host "  .\release.ps1 create v2.0.0-beta 'Beta test'   # Create beta release"
    Write-Host "  .\release.ps1 list                              # Show all releases"
    Write-Host "  .\release.ps1 delete v1.0.0                    # Delete release v1.0.0"
    Write-Host "  .\release.ps1 status                            # Show current status"
    Write-Host ""
    Write-Host "Version Examples:" -ForegroundColor Yellow
    Write-Host "  v1.0.0      - Stable release"
    Write-Host "  v1.1.0      - Minor update"
    Write-Host "  v2.0.0      - Major update"
    Write-Host "  v1.0.0-rc1  - Release candidate"
    Write-Host "  v1.0.0-beta - Beta version"
    Write-Host ""
    Write-Host "What happens when you create a release:" -ForegroundColor Yellow
    Write-Host "  1. 🏷️  Git tag is created locally"
    Write-Host "  2. 📤 Tag is pushed to GitHub"
    Write-Host "  3. 🤖 GitHub Actions starts building"
    Write-Host "  4. 📦 IPK packages are compiled"
    Write-Host "  5. 🎉 Release is created with packages attached"
    Write-Host ""
    Write-Host "Repository: https://github.com/Reunion90/openwrt-ffmpeg-x86" -ForegroundColor Cyan
}

# Main script logic
switch ($Command.ToLower()) {
    "create" {
        New-Release -version $Version -description $Description
    }
    "list" {
        Get-Releases
    }
    "delete" {
        Remove-Release -version $Version
    }
    "status" {
        Get-ReleaseStatus
    }
    "help" {
        Show-Help
    }
    default {
        Write-Error "Unknown command: $Command"
        Write-Host ""
        Show-Help
        exit 1
    }
}
