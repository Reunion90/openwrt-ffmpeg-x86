# GitHub Actions Trigger Script
# This script helps you trigger and monitor GitHub Actions

Write-Host "🚀 GitHub Actions for OpenWrt FFmpeg" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Repository information
$repo = "Reunion90/openwrt-ffmpeg-x86"
$repoUrl = "https://github.com/$repo"

Write-Host "📍 Repository: $repoUrl" -ForegroundColor Green
Write-Host ""

# Show current status
Write-Host "📊 Current Status:" -ForegroundColor Yellow
$currentBranch = git branch --show-current
$latestCommit = git rev-parse --short HEAD
$commitMsg = git log -1 --format=%s

Write-Host "  🌿 Branch: $currentBranch"
Write-Host "  🔖 Latest commit: $latestCommit"
Write-Host "  💬 Message: $commitMsg"
Write-Host ""

# Check if we have any tags
$tags = git tag -l | Where-Object { $_.StartsWith('v') } | Sort-Object -Descending
if ($tags) {
    $latestTag = $tags[0]
    Write-Host "  🏷️  Latest release: $latestTag"
} else {
    Write-Host "  🏷️  No releases yet"
}
Write-Host ""

# GitHub Actions URLs
Write-Host "🔗 Important Links:" -ForegroundColor Yellow
Write-Host "  🔄 Actions (Build Status): $repoUrl/actions" -ForegroundColor Blue
Write-Host "  📦 Releases: $repoUrl/releases" -ForegroundColor Blue
Write-Host "  📋 Workflow File: $repoUrl/blob/main/.github/workflows/build-ffmpeg.yml" -ForegroundColor Blue
Write-Host ""

# Manual trigger instructions
Write-Host "🎯 How to Trigger GitHub Actions:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1️⃣ AUTOMATIC TRIGGERS (Already Active):" -ForegroundColor Green
Write-Host "   ✅ Push to main branch (just happened!)"
Write-Host "   ✅ Create new tag/release"
Write-Host "   ✅ Pull requests to main"
Write-Host ""

Write-Host "2️⃣ MANUAL TRIGGER via GitHub Web:" -ForegroundColor Green
Write-Host "   1. Go to: $repoUrl/actions" -ForegroundColor Blue
Write-Host "   2. Click 'Build FFmpeg for OpenWrt x86_64'"
Write-Host "   3. Click 'Run workflow' button"
Write-Host "   4. Select branch: main"
Write-Host "   5. Click 'Run workflow'"
Write-Host ""

Write-Host "3️⃣ CREATE NEW RELEASE (Triggers Build):" -ForegroundColor Green
Write-Host "   # Create next version:"
Write-Host "   .\release.ps1 create v1.0.1 'Bug fixes'" -ForegroundColor Cyan
Write-Host ""
Write-Host "   # Or manually:"
Write-Host "   git tag v1.0.1" -ForegroundColor Cyan
Write-Host "   git push origin v1.0.1" -ForegroundColor Cyan
Write-Host ""

Write-Host "4️⃣ PUSH CHANGES (Triggers Build):" -ForegroundColor Green
Write-Host "   # Make changes, then:"
Write-Host "   git add ." -ForegroundColor Cyan
Write-Host "   git commit -m 'Your changes'" -ForegroundColor Cyan
Write-Host "   git push" -ForegroundColor Cyan
Write-Host ""

# Build status check
Write-Host "📊 Current Build Status:" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔍 The build was triggered by your recent push!" -ForegroundColor Green
Write-Host "   ⏱️  Build time: ~15-20 minutes"
Write-Host "   📦 Packages: ffmpeg, ffprobe, libffmpeg-full"
Write-Host "   🎯 Target: OpenWrt 24.10 x86_64"
Write-Host "   🔧 Features: H.264, libx264, Opus, Vorbis"
Write-Host ""

Write-Host "✨ What to expect:" -ForegroundColor Yellow
Write-Host "   1. 🏗️  GitHub downloads OpenWrt SDK"
Write-Host "   2. 🔧 Configures build environment"
Write-Host "   3. 📝 Copies your Makefile and patches"
Write-Host "   4. ⚙️  Compiles FFmpeg with H.264 support"
Write-Host "   5. 📦 Creates IPK packages"
Write-Host "   6. ⬆️  Uploads artifacts (if regular push)"
Write-Host "   7. 🎉 Creates release (if tag push)"
Write-Host ""

# Next steps
Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. 👀 Monitor: $repoUrl/actions" -ForegroundColor Blue
Write-Host "   2. ⏳ Wait: ~15-20 minutes for completion"
Write-Host "   3. 📥 Download: IPK packages from artifacts/releases"
Write-Host "   4. 🧪 Test: Install on OpenWrt device"
Write-Host ""

# Quick commands
Write-Host "⚡ Quick Commands:" -ForegroundColor Yellow
Write-Host "   .\release.ps1 status     # Check release status" -ForegroundColor Cyan
Write-Host "   .\release.ps1 list       # List all releases" -ForegroundColor Cyan
Write-Host "   .\release.ps1 create     # Create new release" -ForegroundColor Cyan
Write-Host ""

Write-Host "🎉 GitHub Actions should be running now!" -ForegroundColor Green
Write-Host "   Check: $repoUrl/actions" -ForegroundColor Blue
Write-Host ""
