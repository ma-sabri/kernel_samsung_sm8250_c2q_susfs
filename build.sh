#!/bin/bash

export ARCH=arm64

CROSS_COMPILE=$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
CLANG=$(pwd)/toolchain/llvm-arm-toolchain-ship/10.0/bin/clang
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

IMAGE_DTB=$(pwd)/out/arch/arm64/boot/Image-dtb
LOCATION=$(pwd)

mkdir out
mkdir gorhanhee

make -j16 -C $(pwd) O=$(pwd)/out mrproper
make -j16 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE REAL_CC=$CLANG CLANG_TRIPLE=$CLANG_TRIPLE vendor/x1q_kor_singlex_defconfig
make -j16 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE REAL_CC=$CLANG CLANG_TRIPLE=$CLANG_TRIPLE || exit 1

cp "$IMAGE_DTB" "$(pwd)/AIK/split_img/boot.img-kernel"
cd $(pwd)/AIK
./repackimg.sh

cd "$LOCATION"
cp "$(pwd)/AIK/image-new.img" "$(pwd)/gorhanhee/boot.img"