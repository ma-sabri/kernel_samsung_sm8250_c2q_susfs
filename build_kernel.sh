#!/bin/bash
set -e

echo "=== Wiping Link Obstacles ==="
# Force-remove local placeholders entirely
rm -rf KernelSU-Next
rm -f .gitmodules

echo "=== Fetching Source Archive via Raw HTTP Stream ==="
# Bypasses git entirely to completely eliminate exit code 128 errors
mkdir -p KernelSU-Next
curl -LSs https://github.com | tar -xz -C KernelSU-Next --strip-components=1

echo "=== Configuring Cross-Compilation Parameters ==="
export ARCH=arm64
export SUBARCH=arm64

echo "=== Patching Flat Defconfig Alias ==="
# Resolves the original recursive fallback make infinite loop problem
cp arch/arm64/configs/vendor/samsung/defconfig arch/arm64/configs/samsung_ci_defconfig

echo "=== Generating Config Matrix ==="
mkdir -p out
make O=out ARCH=arm64 samsung_ci_defconfig

echo "=== Commencing Processing Pipeline ==="
make O=out ARCH=arm64 -j$(nproc --all)
