# GitHub Actions Build Troubleshooting Guide

## 🔍 Common Build Errors and Solutions

### 1. **SDK Download Issues**
**Error**: `wget: HTTP 404 Not Found` or `File not found`

**Solution**: Check if OpenWrt SDK URL is correct
```bash
# Test the SDK URL manually
curl -I https://downloads.openwrt.org/releases/24.10.0/targets/x86/64/openwrt-sdk-24.10.0-x86-64_gcc-13.3.0_musl.Linux-x86_64.tar.zst
```

### 2. **Package Path Issues**
**Error**: `make: *** No rule to make target 'package/multimedia/ffmpeg/compile'`

**Solution**: The package structure might be wrong
- Check if `package/Makefile` exists
- Verify the package is copied to the right location

### 3. **Missing Dependencies**
**Error**: `Package 'x264' not found` or `libx264 not available`

**Solution**: x264 package might not be available in feeds
- Need to add x264 to the feeds or build it separately

### 4. **Build Configuration Issues**
**Error**: Configuration options not recognized

**Solution**: OpenWrt package config might have changed

## 🔧 Quick Fixes

### Fix 1: Add x264 Package Build
The OpenWrt SDK might not include x264 by default. Let's add it:
