#!/bin/bash
set -e

echo "=== Wiping Link Obstacles ==="
rm -rf KernelSU-Next
rm -f .gitmodules

echo "=== Streaming Raw HTTP Source Archive ==="
mkdir -p KernelSU-Next
curl -LSs https://github.com | tar -xz -C KernelSU-Next --strip-components=1

echo "=== Setting Cross-Compiler Target Env ==="
export ARCH=arm64
export SUBARCH=arm64

echo "=== Patching Flat Defconfig Alias ==="
# Hard-pointing directly to your verified z3q S20 Ultra layout config file path
cp arch/arm64/configs/vendor/z3q_kor_singlex_defconfig arch/arm64/configs/samsung_ci_defconfig

echo "=== Generating Configuration Objects ==="
mkdir -p out
make O=out ARCH=arm64 samsung_ci_defconfig

echo "=== Commencing Processing Pipeline ==="
make O=out ARCH=arm64 -j$(nproc --all)
