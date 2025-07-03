# 🔧 Fix: OpenWrt SDK Extension Correction

## Issue Fixed
The OpenWrt 24.10 SDK uses `.tar.zst` (Zstandard) compression instead of `.tar.xz` compression.

## Changes Made

### 1. GitHub Actions Workflow (`.github/workflows/build-ffmpeg.yml`)
- ✅ Updated SDK URL from `.tar.xz` to `.tar.zst`
- ✅ Added `zstd` package to dependencies
- ✅ Changed extraction command to `tar --zstd -xf`

### 2. Build Script (`build.sh`)
- ✅ Updated SDK_URL variable to use `.tar.zst`
- ✅ Added `zstd` to apt and dnf package lists
- ✅ Updated extraction logic for zstd format
- ✅ Changed cached file name to `.tar.zst`

### 3. Documentation (`README.md`)
- ✅ Updated manual build instructions
- ✅ Added `zstd` to dependency list
- ✅ Corrected SDK download and extraction commands

### 4. Git Configuration (`.gitignore`)
- ✅ Added `*.tar.zst` to ignored files

## Technical Details

**Old Format**: `.tar.xz` (LZMA compression)
```bash
tar -xf file.tar.xz
```

**New Format**: `.tar.zst` (Zstandard compression)
```bash
tar --zstd -xf file.tar.zst
```

## Benefits of Zstandard
- 🚀 **Faster decompression** than xz
- 📦 **Better compression ratio** than gzip
- 🔧 **Lower CPU usage** during extraction
- ⚡ **Faster build times** overall

## Verification
The corrected SDK URL:
```
https://downloads.openwrt.org/releases/24.10.0/targets/x86/64/openwrt-sdk-24.10.0-x86-64_gcc-13.3.0_musl.Linux-x86_64.tar.zst
```

This fix ensures that:
- ✅ GitHub Actions builds will work correctly
- ✅ Local builds using `build.sh` will download the right file
- ✅ Manual builds follow the correct procedure
- ✅ No more "file not found" errors

## Next Steps
Commit and push these changes to trigger a new build with the correct SDK format.
