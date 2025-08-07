#!/bin/bash

export ARCH=arm64

CROSS_COMPILE=$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
CLANG=$(pwd)/toolchain/llvm-arm-toolchain-ship/10.0/bin/clang
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

IMAGE_DTB=$(pwd)/out/arch/arm64/boot/Image-dtb
LOCATION=$(pwd)
OUT_DIR=$(pwd)/out

mkdir out
mkdir gorhanhee

make -j16 -C $(pwd) O=$OUT_DIR mrproper
make -j16 -C $(pwd) O=$OUT_DIR $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE REAL_CC=$CLANG CLANG_TRIPLE=$CLANG_TRIPLE vendor/x1q_kor_singlex_defconfig
make -j16 -C $(pwd) O=$OUT_DIR $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILE REAL_CC=$CLANG CLANG_TRIPLE=$CLANG_TRIPLE || exit 1

cp "$IMAGE_DTB" "$(pwd)/AIK/split_img/boot.img-kernel"
cd $(pwd)/AIK
./repackimg.sh

cd "$LOCATION"
cp "$(pwd)/AIK/image-new.img" "$(pwd)/gorhanhee/boot.img"

python3 mkdtboimg.py create dtbo.img \
  	--page_size=4096 \
  	--version=0 \
  	--id=0x0 --rev=0x0 --custom0=0x0 --custom1=0x0 --custom2=0x0 --custom3=0x0 \
  	${OUT_DIR}/arch/arm64/boot/dts/samsung/common/kona-sec-system-update-overlay.dtbo --custom0=0x00 --custom1=0x00 --id=0x0 --rev=0x0 \
  	${OUT_DIR}/arch/arm64/boot/dts/samsung/x1q/kona-sec-x1q-kor-overlay-r13.dtbo --custom0=0x00 --custom1=0x00 --id=0x0 --rev=0x0 \
  	${OUT_DIR}/arch/arm64/boot/dts/samsung/x1q/kona-sec-x1q-kor-overlay-r14.dtbo --custom0=0x00 --custom1=0x00 --id=0x0 --rev=0x0

mv "$(pwd)/dtbo.img" "$(pwd)/gorhanhee/dtbo.img"

cd gorhanhee
tar -cvf x1q_SuSFS.tar boot.img dtbo.img