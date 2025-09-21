#!/bin/bash
#
# Motorola G86 Power (Nice) Kernel Build Script
# Android 15

set -e

echo "=== [1] Creating source folder and syncing repo ==="
mkdir -p nice && cd nice

if [ ! -d ".repo" ]; then
    repo init -u https://github.com/dx0101x/motorola_nice_manifest -m default.xml
fi

repo sync -j"$(nproc)"

echo "=== [2] Fixing WORKSPACE vendor paths ==="
WORKSPACE_FILE="WORKSPACE"

if grep -q "../vendor/mediatek" "$WORKSPACE_FILE"; then
    sed -i 's|../vendor/mediatek|vendor/mediatek|g' "$WORKSPACE_FILE"
    echo "✔ Fixed Mediatek vendor paths in WORKSPACE"
else
    echo "✔ WORKSPACE already points to vendor/mediatek"
fi

echo "=== [3] Creating symlinks ==="
ln -sf kernel_device_modules-6.1 kernel_device_modules-mainline
ln -sf kernel_device_modules-6.1 kernel_device_modules

echo "=== [4] Copying nice config ==="
mkdir -p kernel_device_modules-6.1/kernel/configs/ext_config
cp -f kernel_device_modules-6.1/arch/arm64/configs/ext_config/moto-mgk_64_k61-nice.config \
   kernel_device_modules-6.1/kernel/configs/ext_config/moto-mgk_64_k61-nice.config

echo "=== [5] Building kernel ==="
bazel build //kernel-6.1:kernel --//:kernel_version=6.1 --//:internal_config=true

echo "=== [6] Building device modules ==="
export DEFCONFIG_OVERLAYS="ext_config/moto-mgk_64_k61-nice.config"
bazel build //kernel_device_modules-6.1:mgk_64_k61.user

echo "=== [7] Cleaning sources ==="
bazel clean --expunge

echo "=== [8] Build complete! Outputs are located in: ==="
echo "  - Kernel Image: bazel-bin/kernel-6.1/arch/arm64/boot/Image.gz-dtb"
echo "  - Modules:      bazel-bin/kernel_device_modules-6.1/"
