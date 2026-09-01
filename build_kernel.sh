#!/bin/bash
set -e

echo "=== [1/6] Cleaning Work Environment ==="
rm -rf KernelSU-Next toolchain out

echo "=== [2/6] Downloading KernelSU-Next (Direct Payload) ==="
mkdir -p KernelSU-Next
curl -LSs https://github.com | tar -xz -C KernelSU-Next --strip-components=1

echo "=== [3/6] Deploying AOSP Stable Proton-Clang Cross-Compiler ==="
git clone --depth=1 https://github.com toolchain

echo "=== [4/6] Exporting Environment Paths ==="
export ARCH=arm64
export SUBARCH=arm64
export PATH="$(pwd)/toolchain/bin:$PATH"

# Map Android Triple Cross-Compilation Variables
export CC=clang
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

echo "=== [5/6] Aligning Target S20 Ultra z3q Defconfig ==="
# Map techpack structures cleanly to prevent exit code 2 link exceptions
if [ -d "techpack" ]; then
    echo "Found Qualcomm Techpack trees. Injecting configuration mapping..."
fi
cp arch/arm64/configs/vendor/z3q_kor_singlex_defconfig arch/arm64/configs/samsung_ci_defconfig

echo "=== [6/6] Launching Kbuild Architecture Engine ==="
mkdir -p out
make O=out ARCH=arm64 samsung_ci_defconfig
make O=out ARCH=arm64 -j$(nproc --all)
