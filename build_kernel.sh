#!/bin/bash
set -e

echo "=== Overriding Submodule Directories ==="
# Break any existing folder locks before trying to clone
rm -rf KernelSU-Next
rm -f .gitmodules

echo "=== Pulling KernelSU-Next From Raw Remote Tree ==="
# Clone it fresh into the root directory
git clone --depth=1 https://github.com KernelSU-Next

# CRITICAL STEP: Strip the internal git tracking directory out of the cloned folder.
# This prevents GitHub's parent tracking from getting confused and dropping an exit 128 error.
rm -rf KernelSU-Next/.git

echo "=== Initializing Compiling Profiles ==="
export ARCH=arm64
export SUBARCH=arm64

echo "=== Patching Defconfig Loop ==="
cp arch/arm64/configs/vendor/samsung/defconfig arch/arm64/configs/samsung_ci_defconfig

echo "=== Generating Configs ==="
mkdir -p out
make O=out ARCH=arm64 samsung_ci_defconfig

echo "=== Starting Architecture Compilation ==="
make O=out ARCH=arm64 -j$(nproc --all)
