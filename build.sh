#!/bin/bash
#
# Compile script for kernel
#

SECONDS=0 # builtin bash timer
ZIPNAME="sweet-$(date '+%Y%m%d-%H%M').zip"

export ARCH=arm64
export KBUILD_BUILD_USER=aryan
export KBUILD_BUILD_HOST=celeste
export PATH="/home/celeste/aryan/linux-x86/clang-r487747c/bin/:$PATH"
#export PATH="/home/celeste/aryan/lineage/prebuilts/clang/host/linux-x86/clang-r487747c/bin/:$PATH"

if [[ $1 = "-c" || $1 = "--clean" ]]; then
	rm -rf out
	echo "Cleaned output folder"
fi

echo -e "\nStarting compilation...\n"
make O=out ARCH=arm64 sweet_defconfig
#make O=out ARCH=arm64 vendor/sdmsteppe-perf_defconfig vendor/sweet.config
make -j$(nproc) \
    O=out \
    ARCH=arm64 \
    LLVM=1 \
    LLVM_IAS=1 \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi-

kernel="out/arch/arm64/boot/Image.gz"
dtbo="out/arch/arm64/boot/dtbo.img"
dtb="out/arch/arm64/boot/dtb.img"

if [ ! -f "$kernel" ] || [ ! -f "$dtbo" ] || [ ! -f "$dtb" ]; then
	echo -e "\nCompilation failed!"
	exit 1
fi

echo -e "\nKernel compiled succesfully! Zipping up...\n"

if [ -d "$AK3_DIR" ]; then
	cp -r $AK3_DIR AnyKernel3
	git -C AnyKernel3 checkout lisa &> /dev/null
elif ! git clone -q https://github.com/basamaryan/AnyKernel3 -b master AnyKernel3; then
	echo -e "\nAnyKernel3 repo not found locally and couldn't clone from GitHub! Aborting..."
	exit 1
fi

cp $kernel AnyKernel3
cp $dtbo AnyKernel3
cp $dtb AnyKernel3
cd AnyKernel3
zip -r9 "../$ZIPNAME" * -x .git
cd ..
rm -rf AnyKernel3
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
echo "Zip: $ZIPNAME"

if test -z "$(git rev-parse --show-cdup 2>/dev/null)" &&
   head=$(git rev-parse --verify HEAD 2>/dev/null); then
	HASH="$(echo $head | cut -c1-8)"
fi

telegram -f $ZIPNAME -M "Completed in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) ! Latest commit: $HASH"
