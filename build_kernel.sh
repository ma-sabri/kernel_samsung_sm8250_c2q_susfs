#!/bin/bash
set -e

echo "=== 1. Checking Directory Environment ==="
pwd
ls -la

echo "=== 2. Wiping Placeholder Folders ==="
rm -rf KernelSU-Next
rm -f .gitmodules

echo "=== 3. Streaming Raw HTTP Source Archive ==="
mkdir -p KernelSU-Next
curl -LSs https://github.com | tar -xz -C KernelSU-Next --strip-components=1

echo "=== 4. Setting Compiling Architecture Env ==="
export ARCH=arm64
export SUBARCH=arm64

echo "=== 5. Patching Flat Defconfig Alias ==="
# Verify the source file physically exists before attempting a copy
if [ -f "arch/arm64/configs/vendor/samsung/defconfig" ]; then
    cp arch/arm64/configs/vendor/samsung/defconfig arch/arm64/configs/samsung_ci_defconfig
    echo "Successfully mapped samsung_ci_defconfig"
else
    echo "ERROR: arch/arm64/configs/vendor/samsung/defconfig not found!"
    exit 1
fi

echo "=== 6. Generating Configuration Objects ==="
mkdir -p out
make O=out ARCH=arm64 samsung_ci_defconfig

echo "=== 7. Commencing Processing Pipeline ==="
make O=out ARCH=arm64 -j$(nproc --all)
