# 1. 拉取 ImmortalWrt 主线的特定 commit
git clone https://github.com/immortalwrt/immortalwrt.git
cd immortalwrt
git checkout 99ca94091f673607bdcb92ba1f93bda1e811fc93

# 2. 拉取 sx-ui2 的 overlay 仓库
git clone https://github.com/sx-ui2/immortalwrt-be6500-port.git /tmp/be6500-overlay

# 3. 把 overlay 里的内容复制到主线源码里
# target/linux/qualcommax/ 覆盖主线的 target/linux/qualcommax/
# package/ 覆盖主线的 package/
# build-overrides/ 里的配置覆盖主线的默认配置
# kernel-patches/qsdk14-r9/ 里的补丁打进外部 kernel
# source-pins.env 指定所有子模块和外部 kernel 的 commit

# 4. 应用 source-pins.env 里指定的外部源码
# 包括 QSDK 14 external kernel (6.6.116)
# NSS-DP, QCA-SSDK, qca-wifi-oss, wlan-open 等

# 5. 使用 initramfs.config 或 initramfs-minimal.config 作为 .config
cp /tmp/be6500-overlay/initramfs.config .config


cp -r /tmp/be6500-overlay/target/linux/qualcommax/* target/linux/qualcommax/

cp -r /tmp/be6500-overlay/package/* package/
cp -r ../package/* package/
cp -r /tmp/be6500-overlay/include/* include/

cp -r /tmp/be6500-overlay/build-overrides/include/* include/
cp -r /tmp/be6500-overlay/target/linux/qualcommax/* target/linux/qualcommax/
cp -r /tmp/be6500-overlay/build-overrides/feeds.conf.default .
cp -r /tmp/be6500-overlay/build-overrides/qmodem.config .
git clone https://git.codelinaro.org/clo/qsdk/oss/kernel/linux-ipq-6.6.git
cd linux-ipq-6.6
git checkout 16f31b0750888769b5418c1f32f2cd385b09972d
 cp /tmp/be6500-overlay/kernel-patches/qsdk14-r9/853-v6.10-mhi-power-down-keep-dev.patch .
git apply 853-v6.10-mhi-power-down-keep-dev.patch
mkdir -p drivers/bus/mhi/clients
echo "# empty placeholder" > drivers/bus/mhi/clients/Kconfig
echo "obj-y := " > drivers/bus/mhi/clients/Makefile
cd ../

sed -i 's|/home/nara0318.guest/src/qsdk14-r9/linux-ipq-6.6|/home/runner/work/Actions-OpenWrt/Actions-OpenWrt/immortalwrt/linux-ipq-6.6|' .config
#mkdir -p build_dir/toolchain-aarch64_cortex-a53_gcc-13.3.0_musl
#rm -rf build_dir/toolchain-aarch64_cortex-a53_gcc-13.3.0_musl/linux-6.6.116
#ln -sf ~/work/Actions-OpenWrt/Actions-OpenWrt/immortalwrt/linux-ipq-6.6/ build_dir/toolchain-aarch64_cortex-a53_gcc-13.3.0_musl/linux-6.6.116


 ./scripts/feeds update -a
 ./scripts/feeds install -a

#make menuconfig -j4


# 6. make menuconfig 微调，然后 make

