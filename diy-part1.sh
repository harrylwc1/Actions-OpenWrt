git clone https://github.com/x-wrt/x-wrt

git clone https://github.com/coolsnowwolf/lede lede
lede/scripts/feeds update -a
sudo cp patches/copy_file.sh /usr/bin
sudo chmod 755 /usr/bin/copy_file.sh

cp patches/copy_file.sh x-wrt/
sudo cp patches/copy_file1.sh /usr/bin
cp patches/copy_file1.sh x-wrt/
sudo chmod 755 x-wrt/copy_file.sh
cd x-wrt
#####

#wget https://github.com/openwrt/openwrt/commit/b4cc5743d90103a0536b07c618f21bfd5685fbe2.patch -O feeds.patch
#git apply -R --ignore-space-change --ignore-whitespace feeds.patch
sed -i 's/src-git-full video/#src-git-full video/g' feeds.conf.default
sed -i 's/src-git video/#src-git video/g' feeds.conf.default

echo "Job name is $GITHUB_JOB"
#git checkout 610ea1b9994 #x-wrt
#git checkout 0a2ed285e4 #openwrt

#if echo $GITHUB_WORKFLOW_REF |grep openwrt
#then
      # git checkout 424210b #KERNEL 5.15.81

#git1 checkout 22.03_b202210282250 #5.15.74
#git1 checkout 9.0_b202110300939 #5.4.155

#git checkout 9.0_b202110300939 #5.4.155

#git checkout v21.02.7 ; cp $GITHUB_WORKSPACE/patches/600-custom-change-txpower-and-dfs_kernel_v21.02.7.patch $GITHUB_WORKSPACE/patches/600-custom-change-txpower-and-dfs_kernel5.4.patch
#git checkout v21.02.1 # 5.4.154;cp $GITHUB_WORKSPACE/myconfig/config.ramips.v21.02.1 $GITHUB_WORKSPACE/myconfig/config.ramips.2.kernel5.4
#git checkout 0eed96ca5d8 
#cp $GITHUB_WORKSPACE/myconfig/config.ramips.2.kernel5.4 $GITHUB_WORKSPACE/myconfig/config.ramips.2.openwrt
#cp $GITHUB_WORKSPACE/myconfig/config.ramips.2.kernel5.4 x-wrt/.config


#git checkout 0eed96ca5d #kernel 5.4.152
     #   0a2ed285e4
#else
        #git checkout 610ea1b9994
#fi

#cd feeds;mv luci luci.bak;git clone https://github.com/x-wrt/luci
#cd luci; git checkout ea0e494;cd $GITHUB_WORKSPACE/x-wrt/ 


cat package/network/services/ppp/Makefile|grep PKG_RELEASE_VERSION:=
#rm target/linux/ramips/dts/mt7620a.dtsi
#rm target/linux/ramips/dts/mt7620n.dtsi
#rm target/linux/ramips/mt7620/target.mk
#wget https://raw.githubusercontent.com/openwrt/openwrt/main/target/linux/ramips/dts/mt7620a.dtsi -O target/linux/ramips/dts/mt7620a.dtsi
#wget https://raw.githubusercontent.com/openwrt/openwrt/main/target/linux/ramips/dts/mt7620n.dtsi -O target/linux/ramips/dts/mt7620n.dtsi
#wget https://raw.githubusercontent.com/openwrt/openwrt/main/target/linux/ramips/mt7620/target.mk -O target/linux/ramips/mt7620/target.mk


ln -s $GITHUB_WORKSPACE/lede/package/lean $GITHUB_WORKSPACE/x-wrt/package/lean
git clone https://github.com/kenzok8/openwrt-packages.git $GITHUB_WORKSPACE/x-wrt/package/openwrt-packages
git clone https://github.com/kenzok8/small.git $GITHUB_WORKSPACE/x-wrt/package/small


sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default
git pull
git clone https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone https://github.com/muink/luci-app-netspeedtest.git $GITHUB_WORKSPACE/x-wrt/package/luci-app-netspeedtest

#rm -rf `find  $GITHUB_WORKSPACE/x-wrt/feeds -name *filebrowser*`
#rm -rf `find  $GITHUB_WORKSPACE/x-wrt/package -name *filebrowser*`
./scripts/feeds update -a

rm -rf `find  $GITHUB_WORKSPACE/x-wrt/feeds -name *filebrowser*`
rm -rf `find  $GITHUB_WORKSPACE/x-wrt/package -name *filebrowser*`
rm -rf  $GITHUB_WORKSPACE/x-wrt/feeds/luci/applications/luci-app-filebrowser

git clone https://github.com/xiaozhuai/luci-app-filebrowser  $GITHUB_WORKSPACE/x-wrt/feeds/luci/applications/luci-app-filebrowser
./scripts/feeds install -a -f


rm -rf  $GITHUB_WORKSPACE/x-wrt/feeds/luci/applications/luci-app-shadowsocks-libev/                                                       
cp -r $GITHUB_WORKSPACE/package/luci-app-shadowsocks-libev $GITHUB_WORKSPACE/x-wrt/feeds/luci/applications/        

./scripts/feeds update -a  
./scripts/feeds install -a -f  

#cd x-wrt/feeds;mv luci luci.bak;git clone https://github.com/x-wrt/luci
#cd luci; git checkout ea0e494;cd $GITHUB_WORKSPACE/x-wrt/


cd $GITHUB_WORKSPACE/x-wrt    

rm -rf package/openwrt-packages/luci-app-wechatpush
rm -rf feeds/kenzo/luci-app-wechatpush
sudo mkdir -p /workdir
sudo timedatectl set-timezone "$TZ"
sudo chown $USER:$GROUPS /workdir
mkdir -p ../$DRIVERS_DIR 
ln -sf /workdir/x-wrt $GITHUB_WORKSPACE/x-wrt




cat GITHUB_WORKSPACE/myconfig/lang.update >> feeds/luci/modules/luci-mod-status/po/zh_Hant/status.po

# ============================================================
# 多核 busybox top 适配
# CPU_MULTI_CORE=true 时：
#   - 覆盖 sys.lua / processes.js
#   - 仅当 ucode 目录存在时，才覆盖 sys.uc
# 源文件位置：$GITHUB_WORKSPACE/myconfig/
# ============================================================
if [ "$CPU_MULTI_CORE" = "true" ]; then
    echo "==> CPU_MULTI_CORE=true，应用多核 top 补丁"

    SRC_DIR="${GITHUB_WORKSPACE}/myconfig"
    LUCI_DIR="feeds/luci"

    SYS_LUA_SRC="$SRC_DIR/sys.lua"
    SYS_UC_SRC="$SRC_DIR/sys.uc"
    PROCESSES_JS_SRC="$SRC_DIR/processes.js"

    # ---- 检查源文件 ----
    for f in "$SYS_LUA_SRC" "$PROCESSES_JS_SRC"; do
        if [ ! -f "$f" ]; then
            echo "ERROR: 源文件不存在: $f"
            exit 1
        fi
    done
    if [ ! -f "$SYS_UC_SRC" ]; then
        echo "WARN: 源文件不存在: $SYS_UC_SRC（只有 ucode 目录存在时才会用到）"
    fi

    # ---------- sys.lua ----------
    SYS_LUA="$LUCI_DIR/modules/luci-base/luasrc/sys.lua"
    if [ ! -f "$SYS_LUA" ]; then
        SYS_LUA=$(find "$LUCI_DIR" -path '*/luasrc/sys.lua' | head -1)
    fi
    if [ -n "$SYS_LUA" ] && [ -f "$SYS_LUA" ]; then
        [ -f "$SYS_LUA.orig" ] || cp -f "$SYS_LUA" "$SYS_LUA.orig"
        cp -f "$SYS_LUA_SRC" "$SYS_LUA"
        echo "    已覆盖: $SYS_LUA"
    else
        echo "    WARN: 找不到 sys.lua，跳过"
    fi

    # ---------- processes.js ----------
    PROCESSES_JS="$LUCI_DIR/modules/luci-mod-status/htdocs/luci-static/resources/view/status/processes.js"
    if [ ! -f "$PROCESSES_JS" ]; then
        PROCESSES_JS=$(find "$LUCI_DIR" -path '*/view/status/processes.js' | head -1)
    fi
    if [ -n "$PROCESSES_JS" ] && [ -f "$PROCESSES_JS" ]; then
        [ -f "$PROCESSES_JS.orig" ] || cp -f "$PROCESSES_JS" "$PROCESSES_JS.orig"
        cp -f "$PROCESSES_JS_SRC" "$PROCESSES_JS"
        echo "    已覆盖: $PROCESSES_JS"
    else
        echo "    WARN: 找不到 processes.js，跳过"
    fi

    # ---------- sys.uc（仅当 ucode 目录存在） ----------
    UCODE_DIR="$LUCI_DIR/modules/luci-base/ucode"
    if [ -d "$UCODE_DIR" ]; then
        if [ ! -f "$SYS_UC_SRC" ]; then
            echo "    WARN: ucode 目录存在，但 $SYS_UC_SRC 不存在，跳过"
        else
            SYS_UC="$UCODE_DIR/sys.uc"
            if [ ! -f "$SYS_UC" ]; then
                SYS_UC=$(find "$LUCI_DIR" -path '*/ucode/sys.uc' | head -1)
            fi
            if [ -n "$SYS_UC" ] && [ -f "$SYS_UC" ]; then
                [ -f "$SYS_UC.orig" ] || cp -f "$SYS_UC" "$SYS_UC.orig"
                cp -f "$SYS_UC_SRC" "$SYS_UC"
                echo "    已覆盖: $SYS_UC"
            else
                echo "    WARN: ucode 目录存在但找不到 sys.uc，跳过"
            fi
        fi
    else
        echo "    未检测到 ucode 目录，跳过 sys.uc"
    fi

    echo "==> 多核 top 补丁完成"

else
    echo "==> CPU_MULTI_CORE != true，跳过多核 top 补丁"
fi


rm $GITHUB_WORKSPACE/x-wrt/package/feeds/packages/ffmpeg/patches/180-mips-cabac-no-mips16.patch 
cp $GITHUB_WORKSPACE/patches/Makefile.ocserv   $GITHUB_WORKSPACE/x-wrt/feeds/packages/net/ocserv/Makefile
