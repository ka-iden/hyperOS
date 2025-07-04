#!/usr/bin/env bash
set -euo pipefail

# Toolchain (override by exporting e.g. AS=fasm CC=clang QEMU=qemu-system-i386)
AS="${AS:-nasm}"
AS_FLAGS="${AS_FLAGS:--f bin}"
CC="${CC:-gcc}"
CC_FLAGS="${CC_FLAGS:--m32 -ffreestanding -O2 -Wall}"
QEMU="${QEMU:-qemu-system-x86_64}"
DD="${DD:-dd}"

# Paths
SRC_DIR="src"
BUILD_DIR="bin"
BOOT_BIN="$BUILD_DIR/boot.bin"
IMG="$BUILD_DIR/boot.img"

# Check required tools
for tool in "$AS" "$CC" "$QEMU" "$DD"; do
	if ! command -v "$tool" &>/dev/null; then
		echo "Error: '$tool' not found in PATH." >&2
		exit 1
	fi
done

# Prepare build dir
mkdir -p "$BUILD_DIR"

# Assemble bootloader(s)
echo "Assembling bootloader..."
$AS $AS_FLAGS -o "$BOOT_BIN" "$SRC_DIR/boot.asm"

# Create a 1.44MB floppy image
echo "Creating floppy image..."
$DD if=/dev/zero of="$IMG" bs=512 count=2880 status=none
$DD if="$BOOT_BIN" of="$IMG" conv=notrunc status=none

# Run in QEMU
echo "Launching QEMU..."
exec $QEMU -drive format=raw,file="$IMG" -boot order=a