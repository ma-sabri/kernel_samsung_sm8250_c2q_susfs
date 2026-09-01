#!/bin/bash
set -e

echo "=== Ensuring Root Directory Layout ==="
# Force remove directory and any leftover hidden git link artifacts
rm -rf KernelSU-Next
rm -f .gitmodules

echo "=== Manually Pulling Fresh KernelSU-Next Source ==="
# Bypasses submodule tracking entirely by doing a clean, raw directory clone
git clone --depth=1 https://github.com KernelSU-Next

echo "=== Configuring Environment Variables ==="
export ARCH=arm64
export SUBARCH=arm64

echo "=== Patching Defconfig Loop ==="
# Bypasses standard make fallback errors by copying to a flat alias filename
cp arch/arm64/configs/vendor/samsung/defconfig arch/arm64/configs/samsung_ci_defconfig

echo "=== Generating Configs ==="
mkdir -p out
make O=out ARCH=arm64 samsung_ci_defconfig

echo "=== Beginning Compilation Pipeline ==="
make O=out ARCH=arm64 -j$(nproc --all)
