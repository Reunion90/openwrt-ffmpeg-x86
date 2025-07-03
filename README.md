# FFmpeg for OpenWrt x86_64 with H.264 Support

This repository contains the build configuration and GitHub Actions workflow to compile FFmpeg and FFprobe for OpenWrt 24.10 x86_64 with libx264 and H.264 support enabled.

## Features

- **FFmpeg** - Complete multimedia framework
- **FFprobe** - Multimedia stream analyzer  
- **libx264** - H.264/AVC video encoder
- **H.264 decoder** - Hardware-accelerated H.264 decoding
- **Additional codecs** - Opus, Vorbis audio support

## Built Packages

The build process generates the following IPK packages:

- `ffmpeg_*.ipk` - FFmpeg command line tool
- `ffprobe_*.ipk` - FFprobe media analyzer tool
- `libffmpeg-full_*.ipk` - Full-featured FFmpeg libraries
- `libx264_*.ipk` - x264 encoder library

## GitHub Actions Build

The repository includes automated builds using GitHub Actions:

1. **Triggers**: Push to main/master, pull requests, manual workflow dispatch
2. **Environment**: Ubuntu 22.04 with OpenWrt SDK 24.10.0
3. **Architecture**: x86_64 target
4. **Artifacts**: Compiled IPK packages uploaded for 30 days
5. **Releases**: Automatic release creation when tags are pushed

### Build Status

[![Build FFmpeg for OpenWrt x86_64](https://github.com/Reunion90/openwrt-ffmpeg-x86/actions/workflows/build-ffmpeg.yml/badge.svg)](https://github.com/Reunion90/openwrt-ffmpeg-x86/actions/workflows/build-ffmpeg.yml)

## Manual Build Instructions

### Prerequisites

1. Ubuntu 22.04 or similar Linux distribution
2. OpenWrt SDK 24.10.0 for x86_64
3. Required build dependencies

### Build Steps

1. **Install dependencies:**
   ```bash
   sudo apt-get update
   sudo apt-get install -y build-essential clang flex bison g++ gawk \
     gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev \
     python3-distutils rsync unzip zlib1g-dev file wget subversion zstd
   ```

2. **Download OpenWrt SDK:**
   ```bash
   wget https://downloads.openwrt.org/releases/24.10.0/targets/x86/64/openwrt-sdk-24.10.0-x86-64_gcc-13.3.0_musl.Linux-x86_64.tar.zst
   tar --zstd -xf openwrt-sdk-24.10.0-x86-64_gcc-13.3.0_musl.Linux-x86_64.tar.zst
   cd openwrt-sdk-24.10.0-x86-64_gcc-13.3.0_musl.Linux-x86_64
   ```

3. **Copy package files:**
   ```bash
   mkdir -p package/multimedia/ffmpeg
   cp -r /path/to/this/repo/package/* package/multimedia/ffmpeg/
   ```

4. **Update feeds:**
   ```bash
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   ```

5. **Configure build:**
   ```bash
   make defconfig
   echo "CONFIG_PACKAGE_ffmpeg=y" >> .config
   echo "CONFIG_PACKAGE_ffprobe=y" >> .config
   echo "CONFIG_FFMPEG_ENCODER_LIBX264=y" >> .config
   echo "CONFIG_FFMPEG_DECODER_H264=y" >> .config
   make defconfig
   ```

6. **Build packages:**
   ```bash
   make package/multimedia/ffmpeg/compile V=s -j$(nproc)
   ```

7. **Find compiled packages:**
   ```bash
   find bin/packages -name "*.ipk" -path "*/multimedia/*"
   ```

## Installation on OpenWrt

1. **Transfer packages** to your OpenWrt device
2. **Install dependencies** (if not already present):
   ```bash
   opkg update
   opkg install libpthread zlib libbz2
   ```
3. **Install FFmpeg packages:**
   ```bash
   opkg install libffmpeg-full_*.ipk
   opkg install ffmpeg_*.ipk
   opkg install ffprobe_*.ipk
   ```

## Usage Examples

### Basic video encoding with H.264:
```bash
ffmpeg -i input.mp4 -c:v libx264 -c:a copy output.mp4
```

### Probe media file information:
```bash
ffprobe -v quiet -print_format json -show_format -show_streams input.mp4
```

### Convert with specific H.264 settings:
```bash
ffmpeg -i input.avi -c:v libx264 -preset fast -crf 23 -c:a aac output.mp4
```

## Configuration Details

### Enabled Features:
- **GPL license** - Required for x264
- **libx264 encoder** - High-quality H.264 encoding
- **H.264 decoder** - Fast H.264 decoding
- **Opus codec** - Modern audio codec
- **Vorbis codec** - Open source audio codec
- **Threading** - Multi-threaded processing
- **Shared libraries** - Reduced binary size

### Disabled Features:
- Debug symbols (reduces size)
- Documentation (not needed for embedded)
- VAAPI/VDPAU (not available on x86_64 embedded)
- Output devices (not needed)
- LZMA compression (reduces dependencies)

## Troubleshooting

### Common Issues:

1. **Missing dependencies**: Ensure all required packages are installed
2. **Build failures**: Check GitHub Actions logs for detailed error messages
3. **Runtime errors**: Verify all library dependencies are installed on target

### Getting Help:

- Check GitHub Issues for known problems
- Review GitHub Actions workflow logs
- Verify OpenWrt version compatibility

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the build
5. Submit a pull request

## License

This package configuration is released under the same licenses as FFmpeg:
- LGPL-2.1-or-later
- GPL-2.0-or-later 
- LGPL-3.0-or-later

See the FFmpeg source code for detailed license information.

## Links

- [FFmpeg Official Site](https://ffmpeg.org/)
- [OpenWrt Project](https://openwrt.org/)
- [x264 Encoder](https://www.videolan.org/developers/x264.html)
- [OpenWrt SDK Documentation](https://openwrt.org/docs/guide-developer/toolchain/using_the_sdk)
