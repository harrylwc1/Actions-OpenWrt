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

# 6. make menuconfig 微调，然后 make

