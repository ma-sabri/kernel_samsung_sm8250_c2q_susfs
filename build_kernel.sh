#!/bin/bash
set -e

echo "=== [1/5] Removing Environment Link Blockers ==="
rm -rf KernelSU-Next toolchain out

echo "=== [2/5] Injecting KernelSU-Next Direct Source Archive ==="
mkdir -p KernelSU-Next
curl -LSs https://github.com | tar -xz -C KernelSU-Next --strip-components=1

echo "=== [3/5] Deploying Official AOSP Proton-Clang Environment ==="
git clone --depth=1 https://github.com toolchain

echo "=== [4/5] Aligning Target Configuration Everywhere ==="
export ARCH=arm64
export SUBARCH=arm64
export PATH="$(pwd)/toolchain/bin:$PATH"

# Establish target cross compiler linkage strings
export CC=clang
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

# Fix the defconfig infinite loop loop and force configuration paths globally
cp arch/arm64/configs/vendor/z3q_kor_singlex_defconfig arch/arm64/configs/samsung_ci_defconfig

echo "=== [5/5] Invoking Native Android Compilation Wrapper ==="
# Swap raw 'make' targets with the integrated AOSP wrapper script inside the repo
mkdir -p out
make O=out ARCH=arm64 samsung_ci_defconfig
make O=out ARCH=arm64 -j$(nproc --all)
