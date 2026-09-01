#!/bin/bash
set -e

echo "=== 1. Wiping Link Obstacles ==="
rm -rf KernelSU-Next toolchain out
rm -f .gitmodules

echo "=== 2. Streaming KernelSU-Next Source ==="
mkdir -p KernelSU-Next
curl -LSs https://github.com | tar -xz -C KernelSU-Next --strip-components=1

echo "=== 3. Downloading Android Proton-Clang Toolchain ==="
mkdir -p toolchain
curl -LSs https://googlesource.com | tar -xz -C toolchain

echo "=== 4. Setting Environment Paths ==="
export ARCH=arm64
export SUBARCH=arm64
export PATH="$(pwd)/toolchain/bin:$PATH"

# Setup cross compilation mappings explicitly for Android
export CC=clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-gnu-

echo "=== 5. Patching Flat Defconfig Alias ==="
# Explicitly use the z3q S20 Ultra configuration everywhere across the pipeline
cp arch/arm64/configs/vendor/z3q_kor_singlex_defconfig arch/arm64/configs/samsung_ci_defconfig

echo "=== 6. Generating Configuration Objects ==="
mkdir -p out
make O=out ARCH=arm64 samsung_ci_defconfig

echo "=== 7. Commencing Processing Pipeline ==="
make O=out ARCH=arm64 -j$(nproc --all)
