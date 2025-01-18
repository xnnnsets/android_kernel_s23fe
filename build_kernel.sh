#!/bin/bash

#init submodules
git submodule init && git submodule update

#main variables
export ARCH=arm64
export RDIR="$(pwd)"
export KBUILD_BUILD_USER="@ravindu644"
export TARGET_SOC=s5e9925
export LLVM=1 LLVM_IAS=1
export PLATFORM_VERSION=12
export ANDROID_MAJOR_VERSION=s

#export toolchain paths
export PATH=${RDIR}/toolchains/clang-r416183b/bin:$PATH
export BUILD_CROSS_COMPILE="${RDIR}/toolchains/gcc/arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-"

#build dir
if [ ! -d "${RDIR}/build" ]; then
    mkdir -p "${RDIR}/build"
else
    rm -rf "${RDIR}/build" && mkdir -p "${RDIR}/build"
fi

#dev
if [ -z "$BUILD_KERNEL_VERSION" ]; then
    export BUILD_KERNEL_VERSION="dev"
fi

#setting up localversion
echo -e "CONFIG_LOCALVERSION_AUTO=n\nCONFIG_LOCALVERSION=\"-ravindu644-${BUILD_KERNEL_VERSION}\"\n" > "${RDIR}/arch/arm64/configs/version.config"

#build options
export ARGS="
-j$(nproc) \
ARCH=arm64 \
CROSS_COMPILE=${BUILD_CROSS_COMPILE} \
CC=clang
PLATFORM_VERSION=12 \
ANDROID_MAJOR_VERSION=s \
LLVM=1 \
LLVM_IAS=1 \
TARGET_SOC=s5e9925 \
"

#build kernel image
build_kernel(){
    cd "${RDIR}"
    make ${ARGS} clean && make ${ARGS} mrproper
    make ${ARGS} s5e9925-r11sxxx_defconfig custom.config version.config
    make ${ARGS} menuconfig
    make ${ARGS}|| exit 1
    cp ${RDIR}/arch/arm64/boot/Image* ${RDIR}/build
}

build_kernel
