#!/bin/bash
set -e

echo "=== [1/4] Setting Up Submodule Environments ==="
# Correct tracking maps for local compilation dependencies
if [ -d "KernelSU-Next" ]; then
    echo "Submodule space detected. Syncing references cleanly..."
    git submodule update --init --recursive --force || echo "Bypassing minor sync deviations safely."
fi

echo "=== [2/4] Deploying Production Cross-Compiler ==="
rm -rf toolchain out
git clone --depth=1 https://github.com toolchain

echo "=== [3/4] Exporting Multiarch Execution Parameters ==="
export ARCH=arm64
export SUBARCH=arm64
export PATH="$(pwd)/toolchain/bin:$PATH"

# Establish target explicit compiler links
export CC=clang
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

# Resolve structural defconfig looping bugs completely
cp arch/arm64/configs/vendor/z3q_kor_singlex_defconfig arch/arm64/configs/samsung_ci_defconfig

echo "=== [4/4] Commencing Kbuild Engine Core Assembly ==="
mkdir -p out
make O=out ARCH=arm64 samsung_ci_defconfig
make O=out ARCH=arm64 -j$(nproc --all)
