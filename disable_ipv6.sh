cd ~/work/Actions-OpenWrt/Actions-OpenWrt/x-wrt

# ========= 第 1 层：全局默认关掉 IPV6 =========
# 找到定义
grep -rn "^config IPV6$" config/ 2>/dev/null
# 找到后手动编辑，把 default y 改成 default n
# 或者如果找不到，用 include/ 下的：

grep -rn "IPV6" include/target.mk 2>/dev/null

# ========= 第 2 层：删掉 target 默认包的 IPv6 =========
grep -rn "odhcp6c\|odhcpd-ipv6only" include/target.mk target/linux/*/Makefile 2>/dev/null
# 找到后手动编辑，把 odhcp6c odhcpd-ipv6only 删掉

# ========= 第 3 层：删掉 LuCI 里的 luci-proto-ipv6 =========
sed -i '/+IPV6:luci-proto-ipv6/d' feeds/luci/collections/luci-light/Makefile 2>/dev/null
sed -i '/+IPV6:luci-proto-ipv6/d' feeds/luci/collections/luci-nginx/Makefile 2>/dev/null
