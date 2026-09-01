#!/bin/bash
set -e

echo "=== [1/4] Overriding Ghost Submodule Directories ==="
# Prevent old gitindex mappings from locking the folder hierarchy
rm -rf KernelSU-Next toolchain out
rm -f .gitmodules

echo "=== [2/4] Deploying Clean KernelSU-Next Submodule ==="
mkdir -p KernelSU-Next
curl -LSs https://github.com | tar -xz -C KernelSU-Next --strip-components=1

echo "=== [3/4] Pulling Standalone Proton-Clang Environment ==="
git clone --depth=1 https://github.com toolchain

echo "=== [4/4] Activating Cross-Compiler Environment Variables ==="
export ARCH=arm64
export SUBARCH=arm64
export PATH="$(pwd)/toolchain/bin:$PATH"

# Map precise compiler execution variables
export CC=clang
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

# Resolve the Kbuild configuration recursive make loop error
cp arch/arm64/configs/vendor/z3q_kor_singlex_defconfig arch/arm64/configs/samsung_ci_defconfig

echo "=== [5/5] Commencing Production Kernel Assembly Pipeline ==="
mkdir -p out
make O=out ARCH=arm64 samsung_ci_defconfig
make O=out ARCH=arm64 -j$(nproc --all)
