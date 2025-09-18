# Motorola Edge 60 Fusion (Scout) kernel manifest
- Release tag: MMI-V1UI35H.11-39-16
- Android 15

## 1. Create folder & sync repo
<pre>cd ~/
mkdir -p Scout && cd Scout
repo init -u https://github.com/Notganesh/motorola_scout_manifest.git -m default.xml
repo sync -j$(nproc)</pre>

## 2. Create symlinks
<pre>ln -s kernel_device_modules-6.1 kernel_device_modules-mainline
ln -s kernel_device_modules-6.1 kernel_device_modules</pre>

## 3. Copy  config
<pre>mkdir -p kernel_device_modules-6.1/kernel/configs/ext_config
cp -r kernel_device_modules-6.1/arch/arm64/configs/ext_config/moto-mgk_64_k61-scout.config \
   kernel_device_modules-6.1/kernel/configs/ext_config/moto-mgk_64_k61-scout.config</pre>

## 4. Build kernel
<pre>bazel build //kernel-6.1:kernel --//:kernel_version=6.1 --//:internal_config=true</pre>

## 5. Build device modules
<pre>export DEFCONFIG_OVERLAYS="ext_config/moto-mgk_64_k61-scout.config"
bazel build //kernel_device_modules-6.1:mgk_64_k61.user</pre>

## 6. Clean sources
<pre>bazel clean --expunge </pre>
