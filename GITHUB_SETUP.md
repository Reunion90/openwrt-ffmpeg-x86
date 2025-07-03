# GitHub Setup Guide

This guide will help you set up this FFmpeg OpenWrt build project on GitHub with automated builds.

## 🚀 Quick Setup

### Step 1: Create GitHub Repository

1. **Go to GitHub** and sign in to your account
2. **Click "New repository"** or go to https://github.com/new
3. **Repository settings**:
   - Repository name: `openwrt-ffmpeg-x86`
   - Description: `FFmpeg and FFprobe packages for OpenWrt 24.10 x86_64 with H.264 and libx264 support`
   - Visibility: `Public` (recommended for open source)
   - ✅ Initialize with README: **DO NOT CHECK** (we already have files)
   - ✅ Add .gitignore: **DO NOT CHECK** (we already have one)
   - ✅ Choose a license: **DO NOT CHECK** (we'll add later if needed)

4. **Click "Create repository"**

### Step 2: Push Local Code to GitHub

From your local terminal in the project directory:

```bash
# Add GitHub remote (replace 'yourusername' with your GitHub username)
git remote add origin https://github.com/Reunion90/openwrt-ffmpeg-x86.git

# Push code to GitHub
git branch -M main
git push -u origin main
```

### Step 3: Verify GitHub Actions

1. **Go to your repository** on GitHub
2. **Click the "Actions" tab**
3. **You should see**:
   - "Build FFmpeg for OpenWrt x86_64" workflow
   - It may start automatically, or you can trigger it manually

### Step 4: Enable GitHub Actions (if needed)

If Actions don't start automatically:

1. **Go to Settings** → **Actions** → **General**
2. **Under "Actions permissions"** select:
   - ✅ "Allow all actions and reusable workflows"
3. **Under "Workflow permissions"** select:
   - ✅ "Read and write permissions"
   - ✅ "Allow GitHub Actions to create and approve pull requests"

## 🔧 Manual Trigger

To manually start a build:

1. **Go to Actions tab** in your GitHub repository
2. **Click "Build FFmpeg for OpenWrt x86_64"**
3. **Click "Run workflow"** button
4. **Select branch** (usually `main`)
5. **Click "Run workflow"**

## 📦 Download Built Packages

After a successful build:

1. **Go to Actions tab**
2. **Click on a completed workflow run**
3. **Scroll down to "Artifacts"**
4. **Download**: `ffmpeg-openwrt-x86_64-packages`
5. **Extract the ZIP** to get IPK files

## 🏷️ Creating Releases

To create automatic releases with packages:

1. **Create a tag** from your local repository:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **GitHub Actions will**:
   - Build the packages
   - Create a new release
   - Attach IPK files to the release

## 🔍 Monitoring Builds

### Build Status Badge

The README includes a build status badge:
```markdown
[![Build FFmpeg for OpenWrt x86_64](https://github.com/Reunion90/openwrt-ffmpeg-x86/actions/workflows/build-ffmpeg.yml/badge.svg)](https://github.com/Reunion90/openwrt-ffmpeg-x86/actions/workflows/build-ffmpeg.yml)
```

### Email Notifications

GitHub will send email notifications for:
- ✅ Successful builds
- ❌ Failed builds
- 🔄 First-time workflows

## 📋 Workflow Features

The GitHub Actions workflow includes:

### **Triggers**
- `push` to `main` or `master` branches
- `pull_request` to `main` or `master` branches
- `workflow_dispatch` for manual triggers

### **Build Process**
1. **Setup**: Ubuntu 22.04 runner
2. **Dependencies**: Install OpenWrt SDK dependencies
3. **SDK Download**: OpenWrt 24.10.0 x86_64 SDK
4. **Package Copy**: Copy our Makefile and patches
5. **Configuration**: Enable FFmpeg and H.264 support
6. **Build**: Compile packages with parallel jobs
7. **Artifacts**: Collect and upload IPK files

### **Outputs**
- **Artifacts**: Available for 30 days
- **Releases**: Permanent storage for tagged versions

## 🐛 Troubleshooting

### Build Failures

1. **Check Actions logs**:
   - Go to Actions → Click failed run → Expand log sections

2. **Common issues**:
   - Network timeouts downloading SDK
   - Missing dependencies in package definition
   - Compilation errors in FFmpeg

3. **Local testing**:
   ```bash
   ./build.sh --no-deps  # Test build locally
   ```

### Workflow Not Running

1. **Check repository settings**:
   - Settings → Actions → General
   - Ensure Actions are enabled

2. **Check file permissions**:
   - Workflow file should be in `.github/workflows/`
   - File should be valid YAML

3. **Check branch protection**:
   - Some organizations disable Actions on forks
   - Ensure you have write access

## 🔒 Security Considerations

### Permissions

The workflow uses:
- `GITHUB_TOKEN` for creating releases
- No external secrets required
- Read/write permissions for artifacts

### Dependencies

- Downloads from official OpenWrt mirrors
- Uses official Ubuntu packages
- No third-party package managers

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [OpenWrt SDK Guide](https://openwrt.org/docs/guide-developer/toolchain/using_the_sdk)
- [FFmpeg Compilation Guide](https://trac.ffmpeg.org/wiki/CompilationGuide)

## 🎯 Next Steps

1. ✅ **Push to GitHub** (follow Step 2 above)
2. ✅ **Verify build** runs successfully
3. ✅ **Download packages** and test on OpenWrt device
4. ✅ **Create first release** with a git tag
5. ✅ **Share your repository** with the community

---

**Happy building!** 🚀
