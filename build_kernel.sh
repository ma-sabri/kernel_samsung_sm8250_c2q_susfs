#!/bin/bash
set -e

echo "=== Setting Up KernelSU-Next ==="
rm -rf KernelSU-Next
git clone --depth=1 https://github.com KernelSU-Next

echo "=== Configuring Environment Variables ==="
export ARCH=arm64
export SUBARCH=arm64

echo "=== Patching Defconfig Loop ==="
cp arch/arm64/configs/vendor/samsung/defconfig arch/arm64/configs/samsung_ci_defconfig

echo "=== Generating Configs ==="
mkdir -p out
make O=out ARCH=arm64 samsung_ci_defconfig

echo "=== Beginning Compilation Pipeline ==="
make O=out ARCH=arm64 -j$(nproc --all)
