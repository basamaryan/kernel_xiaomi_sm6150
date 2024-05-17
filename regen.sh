#!/bin/bash

# Array of device names
devices=("davinci" "phoenix" "sweet" "toco" "tucana")

# Loop through the devices
for device in "${devices[@]}"
do
    echo "Generating defconfig for $device"
    make ARCH=arm64 O=out "${device}"_defconfig
    make ARCH=arm64 O=out menuconfig
    cp out/.config "arch/arm64/configs/${device}_defconfig"
    rm -rf out
    echo "Defconfig generated for $device"
    echo ""
done

echo "Defconfig generation completed for all devices."
