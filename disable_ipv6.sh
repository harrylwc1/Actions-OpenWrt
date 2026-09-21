#!/bin/bash
#
# disable_ipv6_all.sh
# 用途：永久禁用 OpenWrt 所有 router model 的 IPv6
# 用法：在 OpenWrt 源码根目录执行 ./disable_ipv6_all.sh
#
cd ~/work/Actions-OpenWrt/Actions-OpenWrt/x-wrt
set -e

# ========= 检查当前目录 =========
if [ ! -f "include/target.mk" ]; then
    echo "错误：请在 OpenWrt 源码根目录执行此脚本"
    exit 1
fi

echo "==== 开始禁用 IPv6（所有 router model）===="

# ========= 1. 备份 =========
echo "[1/6] 备份文件..."
for f in include/target.mk; do
    [ -f "$f" ] && cp "$f" "${f}.bak.$(date +%Y%m%d)" && echo "  备份：$f"
done
for f in target/linux/*/Makefile; do
    [ -f "$f" ] && cp "$f" "${f}.bak.$(date +%Y%m%d)"
done
echo "  备份完成"

# ========= 2. 删除 include/target.mk 里的 IPv6 默认包 =========
echo "[2/6] 修改 include/target.mk ..."
sed -i '/^\s*odhcp6c\s*\\\?$/d' include/target.mk
sed -i '/^\s*odhcpd-ipv6only\s*\\\?$/d' include/target.mk
grep -n "odhcp6c\|odhcpd-ipv6only" include/target.mk && echo "  ⚠ include/target.mk 还有残留" || echo "  ✓ include/target.mk 清理完成"

# ========= 3. 删除各 target 的 IPv6 默认包 =========
echo "[3/6] 修改 target/linux/*/Makefile ..."
for f in target/linux/*/Makefile; do
    sed -i '/^\s*odhcp6c\s*\\\?$/d' "$f"
    sed -i '/^\s*odhcpd-ipv6only\s*\\\?$/d' "$f"
done
grep -rn "odhcp6c\|odhcpd-ipv6only" target/linux/*/Makefile 2>/dev/null && echo "  ⚠ target Makefile 还有残留" || echo "  ✓ target Makefile 清理完成"

# ========= 4. 删除 LuCI 里的 luci-proto-ipv6 依赖 =========
echo "[4/6] 修改 feeds/luci 里的 luci-proto-ipv6 ..."
LUCI_FILES=$(grep -rl "luci-proto-ipv6" feeds/luci/ 2>/dev/null | grep -v "\.po" || true)
if [ -n "$LUCI_FILES" ]; then
    for f in $LUCI_FILES; do
        cp "$f" "${f}.bak.$(date +%Y%m%d)"
        sed -i '/luci-proto-ipv6/d' "$f"
        echo "  已处理：$f"
    done
else
    echo "  ✓ 未发现 luci-proto-ipv6 依赖"
fi
grep -rn "luci-proto-ipv6" feeds/luci/ 2>/dev/null | grep -v "\.po" && echo "  ⚠ 还有残留" || echo "  ✓ LuCI 清理完成"

# ========= 5. 修改 .config，关掉所有 IPv6 =========
echo "[5/6] 修改 .config ..."
if [ ! -f ".config" ]; then
    echo "  ⚠ 没有 .config，跳过。请先 make menuconfig 或用 config 文件初始化"
else
    # 5.1 全局与内核
    for opt in \
        CONFIG_IPV6 \
        CONFIG_KERNEL_IPV6 \
        CONFIG_KERNEL_IPV6_MULTIPLE_TABLES \
        CONFIG_KERNEL_IPV6_SUBTREES \
        CONFIG_KERNEL_IPV6_MROUTE \
        CONFIG_KERNEL_IPV6_MROUTE_MULTIPLE_TABLES \
        CONFIG_KERNEL_IPV6_PIMSM_V2 \
        CONFIG_KERNEL_IPV6_SEG6_LWTUNNEL \
        CONFIG_KERNEL_MPTCP_IPV6 \
        CONFIG_BUSYBOX_DEFAULT_FEATURE_IPV6 \
        CONFIG_BUSYBOX_CONFIG_FEATURE_IPV6 \
        CONFIG_DEFAULT_odhcp6c \
        CONFIG_DEFAULT_odhcpd-ipv6only \
        CONFIG_KEEPALIVED_IP6TABLES \
        ; do
        sed -i "s/^${opt}=y/# ${opt} is not set/" .config
        sed -i "s/^${opt}=m/# ${opt} is not set/" .config
    done

    # 5.2 用户态软件包
    for pkg in \
        luci-proto-ipv6 \
        odhcp6c \
        odhcpd-ipv6only \
        odhcpd \
        kmod-ip6tables \
        ip6tables-nft \
        ip6tables \
        libip6tc \
        kmod-ebtables-ipv6 \
        ; do
        sed -i "s/^CONFIG_PACKAGE_${pkg}=y/# CONFIG_PACKAGE_${pkg} is not set/" .config
        sed -i "s/^CONFIG_PACKAGE_${pkg}=m/# CONFIG_PACKAGE_${pkg} is not set/" .config
    done

    echo "  .config 中剩余 IPv6 项："
    grep -iE 'ipv6|ip6|odhcp6' .config | grep -v '#' || echo "  ✓ 全部关掉"
fi

# ========= 6. 完成 =========
echo "[6/6] 完成！"
echo ""
echo "==== 后续步骤 ===="
echo "1. 不要运行 make defconfig 或 make menuconfig"
echo "2. 直接编译："
echo "     make -j\$(nproc) 2>&1 | tail -40"
echo "3. 查看固件大小："
echo "     ls -lh bin/targets/*/*/*.bin"
echo ""
echo "==== 恢复方法 ===="
echo "如果出问题，用备份还原："
echo "     cp include/target.mk.bak.YYYYMMDD include/target.mk"
echo "     cp target/linux/*/Makefile.bak.YYYYMMDD target/linux/*/Makefile"
echo "     cp feeds/luci/**/Makefile.bak.YYYYMMDD feeds/luci/**/Makefile"
