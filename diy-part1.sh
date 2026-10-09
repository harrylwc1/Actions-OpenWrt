#!/bin/bash
set -e

# ========== 基础目录 ==========
cd "$GITHUB_WORKSPACE"

git clone https://github.com/x-wrt/x-wrt
git clone https://github.com/coolsnowwolf/lede lede

# lede 的 feed 更新（保留原逻辑）
lede/scripts/feeds update -a

# ========== copy_file 脚本 ==========
sudo cp patches/copy_file.sh /usr/bin
sudo chmod 755 /usr/bin/copy_file.sh
cp patches/copy_file.sh x-wrt/

sudo cp patches/copy_file1.sh /usr/bin
cp patches/copy_file1.sh x-wrt/
sudo chmod 755 x-wrt/copy_file.sh

cd x-wrt

# ========== feeds.conf.default 配置 ==========
# 注释掉 video 相关源
sed -i 's/src-git-full video/#src-git-full video/g' feeds.conf.default
sed -i 's/src-git video/#src-git video/g' feeds.conf.default

# 追加 kenzo / small 源（仅追加一次）
grep -q "src-git kenzo" feeds.conf.default || \
    sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
grep -q "src-git small" feeds.conf.default || \
    sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default

echo "Job name is $GITHUB_JOB"

# ========== 主仓库 revert（带判断，避免匹配不到时报错） ==========
HASH=$(git log --grep="use admin as the default" -n 1 --format="%H" || true)
if [ -n "$HASH" ]; then
    git revert --no-edit "$HASH" || echo "revert 失败，跳过"
else
    echo "未找到匹配 'use admin as the default' 的提交，跳过 revert"
fi

# ========== 第三方包 clone ==========
ln -s "$GITHUB_WORKSPACE/lede/package/lean" "$GITHUB_WORKSPACE/x-wrt/package/lean"

git clone https://github.com/kenzok8/openwrt-packages.git "$GITHUB_WORKSPACE/x-wrt/package/openwrt-packages"
git clone https://github.com/kenzok8/small.git "$GITHUB_WORKSPACE/x-wrt/package/small"

git clone https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone https://github.com/muink/luci-app-netspeedtest.git "$GITHUB_WORKSPACE/x-wrt/package/luci-app-netspeedtest"

# ========== luci-app-eqos Makefile 路径修复 ==========
EQOS_MK="$GITHUB_WORKSPACE/x-wrt/package/openwrt-packages/luci-app-eqos/Makefile"
if [ -f "$EQOS_MK" ]; then
    sed -i 's|\./files/|./root/|g' "$EQOS_MK"
    # 删除 hotplug.d/iface 相关行（root 下不存在该文件）
    sed -i '/hotplug\.d\/iface/d' "$EQOS_MK"
    echo "已修复 luci-app-eqos Makefile"
fi

# ========== 清理 filebrowser / wechatpush ==========
sudo rm -rf "$GITHUB_WORKSPACE"/x-wrt/package/openwrt-packages/*filebrowser*
rm -rf "$GITHUB_WORKSPACE"/x-wrt/feeds/luci/applications/luci-app-filebrowser
rm -rf package/openwrt-packages/luci-app-wechatpush
rm -rf feeds/kenzo/luci-app-wechatpush

# ========== 第一次 feeds update / install ==========
# 清理旧 feeds，避免本地历史与远程分叉导致 fast-forward 失败
rm -rf feeds
./scripts/feeds update -a
./scripts/feeds install -a -f

# ========== 替换 shadowsocks-libev ==========
rm -rf "$GITHUB_WORKSPACE"/x-wrt/feeds/luci/applications/luci-app-shadowsocks-libev/
cp -r "$GITHUB_WORKSPACE"/package/luci-app-shadowsocks-libev "$GITHUB_WORKSPACE"/x-wrt/feeds/luci/applications/

# ========== 第二次 feeds install（重建链接，保留原逻辑） ==========
./scripts/feeds install -a -f

# ========== 清理 filebrowser（feeds install 之后可能又被链接回来） ==========
rm -rf $(find "$GITHUB_WORKSPACE"/x-wrt/feeds -name '*filebrowser*' 2>/dev/null || true)
rm -rf $(find "$GITHUB_WORKSPACE"/x-wrt/package -name '*filebrowser*' 2>/dev/null || true)

# ========== workdir / 时区 ==========
cd "$GITHUB_WORKSPACE/x-wrt"
sudo mkdir -p /workdir
sudo timedatectl set-timezone "$TZ" || true
sudo chown "$USER:$GROUPS" /workdir
mkdir -p "../$DRIVERS_DIR"
ln -sf /workdir/x-wrt "$GITHUB_WORKSPACE/x-wrt"

# ========== 多核 top 补丁 ==========
if [ "$CPU_MULTI_CORE" = "true" ]; then
    echo "==> CPU_MULTI_CORE=true，应用多核 top 补丁"

    SRC_DIR="${GITHUB_WORKSPACE}/myconfig"
    LUCI_DIR="${GITHUB_WORKSPACE}/x-wrt/feeds/luci"

    # sys.lua
    SYS_LUA="$LUCI_DIR/modules/luci-lua-runtime/luasrc/sys.lua"
    [ -f "$SYS_LUA.orig" ] || cp -f "$SYS_LUA" "$SYS_LUA.orig"
    cp -f "$SRC_DIR/sys.lua" "$SYS_LUA"
    echo "    已覆盖: $SYS_LUA"

    # processes.js
    PROCESSES_JS="$LUCI_DIR/modules/luci-mod-status/htdocs/luci-static/resources/view/status/processes.js"
    [ -f "$PROCESSES_JS.orig" ] || cp -f "$PROCESSES_JS" "$PROCESSES_JS.orig"
    cp -f "$SRC_DIR/processes.js" "$PROCESSES_JS"
    echo "    已覆盖: $PROCESSES_JS"

    # sys.uc（仅当 ucode 目录存在）
    if [ -d "$LUCI_DIR/modules/luci-base/ucode" ]; then
        SYS_UC="$LUCI_DIR/modules/luci-base/ucode/sys.uc"
        [ -f "$SYS_UC.orig" ] || cp -f "$SYS_UC" "$SYS_UC.orig"
        cp -f "$SRC_DIR/sys.uc" "$SYS_UC"
        echo "    已覆盖: $SYS_UC"
    else
        echo "    未检测到 ucode 目录，跳过 sys.uc"
    fi

    # base.po 翻译
    PO_HANT="$LUCI_DIR/modules/luci-base/po/zh_Hant/base.po"
    PO_HANS="$LUCI_DIR/modules/luci-base/po/zh_Hans/base.po"

    add_if_missing() {
        PO="$1"; msgid="$2"; msgstr="$3"
        if grep -qF "msgid \"$msgid\"" "$PO"; then
            echo "    [exists] $msgid"
        else
            printf '\nmsgid "%s"\nmsgstr "%s"\n' "$msgid" "$msgstr" >> "$PO"
            echo "    [added ] $msgid"
        fi
    }

    [ -f "$PO_HANT" ] && {
        add_if_missing "$PO_HANT" "core"              "核心"
        add_if_missing "$PO_HANT" "CPU core"          "CPU 核心"
        add_if_missing "$PO_HANT" "Current Boot Part" "系統分區"
        add_if_missing "$PO_HANT" "Temperature"       "溫度"
    }

    [ -f "$PO_HANS" ] && {
        add_if_missing "$PO_HANS" "core"              "核心"
        add_if_missing "$PO_HANS" "CPU core"          "CPU 核心"
        add_if_missing "$PO_HANS" "Current Boot Part" "系统分区"
        add_if_missing "$PO_HANS" "Temperature"       "温度"
    }

    echo "==> 多核 top 补丁完成"
else
    echo "==> CPU_MULTI_CORE != true，跳过多核 top 补丁"
fi

# ========== ffmpeg 补丁删除（feeds install 之后执行，确保链接存在） ==========
FFMPEG_PATCH="$GITHUB_WORKSPACE/x-wrt/package/feeds/packages/ffmpeg/patches/180-mips-cabac-no-mips16.patch"
if [ -f "$FFMPEG_PATCH" ]; then
    rm -f "$FFMPEG_PATCH"
    echo "已删除 ffmpeg 补丁: $FFMPEG_PATCH"
else
    echo "未找到 ffmpeg 补丁，跳过"
fi

# ========== ocserv Makefile 替换 ==========
cp "$GITHUB_WORKSPACE"/patches/Makefile.ocserv "$GITHUB_WORKSPACE"/x-wrt/feeds/packages/net/ocserv/Makefile

echo "==> diy-part1.sh 执行完成"
