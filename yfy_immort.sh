echo "set paste" >> ~/.vimrc
git clone https://github.com/VIKINGYFY/immortalwrt x-wrt
cp myconfig/config.yfy.2 x-wrt/.config

sudo cp patches/copy_file.sh /usr/bin
sudo chmod 755 /usr/bin/copy_file.sh
cp patches/copy_file.sh x-wrt/
chmod 755 x-wrt/copy_file.sh
cd x-wrt
./scripts/feeds update -a
./scripts/feeds install -a -f



cd $GITHUB_WORKSPACE/x-wrt    

sudo mkdir -p /workdir
sudo timedatectl set-timezone "$TZ"
sudo chown $USER:$GROUPS /workdir
mkdir -p ../$DRIVERS_DIR 
ln -sf /workdir/x-wrt $GITHUB_WORKSPACE/x-wrt


if [ "$CPU_MULTI_CORE" = "true" ]; then
    echo "==> CPU_MULTI_CORE=true，应用多核 top 补丁"

    SRC_DIR="${GITHUB_WORKSPACE}/myconfig"
    LUCI_DIR="${GITHUB_WORKSPACE}/x-wrt/feeds/luci"

    SYS_LUA="$LUCI_DIR/modules/luci-lua-runtime/luasrc/sys.lua"
    [ -f "$SYS_LUA.orig" ] || cp -f "$SYS_LUA" "$SYS_LUA.orig"
    cp -f "$SRC_DIR/sys.lua" "$SYS_LUA"
    echo "    已覆盖: $SYS_LUA"

    PROCESSES_JS="$LUCI_DIR/modules/luci-mod-status/htdocs/luci-static/resources/view/status/processes.js"
    [ -f "$PROCESSES_JS.orig" ] || cp -f "$PROCESSES_JS" "$PROCESSES_JS.orig"
    cp -f "$SRC_DIR/processes.js" "$PROCESSES_JS"
    echo "    已覆盖: $PROCESSES_JS"

    if [ -d "$LUCI_DIR/modules/luci-base/ucode" ]; then
        SYS_UC="$LUCI_DIR/modules/luci-base/ucode/sys.uc"
        [ -f "$SYS_UC.orig" ] || cp -f "$SYS_UC" "$SYS_UC.orig"
        cp -f "$SRC_DIR/sys.uc" "$SYS_UC"
        echo "    已覆盖: $SYS_UC"
    else
        echo "    未检测到 ucode 目录，跳过 sys.uc"
    fi

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


cp -r $GITHUB_WORKSPACE/package/* $GITHUB_WORKSPACE/x-wrt/package/

cd  $GITHUB_WORKSPACE/x-wrt/package/                              
cd $GITHUB_WORKSPACE/x-wrt/
git clone https://github.com/tvheadend/tvheadend.git
cp -r $GITHUB_WORKSPACE/x-wrt/tvheadend/.git $GITHUB_WORKSPACE/x-wrt/package/tvheadend/files/
sudo rm -rf  feeds/packages/multimedia/tvheadend/


#cp $GITHUB_WORKSPACE/patches/0003-mutils_time.patch $GITHUB_WORKSPACE/x-wrt/package/feeds/packages/mailsend/patches/
#cp $GITHUB_WORKSPACE/patches/030-h264-mips.patch $GITHUB_WORKSPACE/x-wrt/feeds/packages/multimedia/ffmpeg/patches/
#cp $GITHUB_WORKSPACE/patches/Makefile.libx264 $GITHUB_WORKSPACE/x-wrt/package/feeds/packages/libx264/Makefile
#cp $GITHUB_WORKSPACE/patches/Makefile.pdnsd-alt $GITHUB_WORKSPACE/x-wrt/package/feeds/small/pdnsd-alt/Makefile
#cp $GITHUB_WORKSPACE/patches/Makefile.simple-obfs $GITHUB_WORKSPACE/x-wrt/package/feeds/small/simple-obfs/Makefile
#cp $GITHUB_WORKSPACE/patches/Makefile.simple-obfs $GITHUB_WORKSPACE/x-wrt/package/simple-obfs/Makefile
#cp $GITHUB_WORKSPACE/patches/Makefile.ss $GITHUB_WORKSPACE/x-wrt/package/feeds/small/shadowsocks-libev/Makefile



TARGET_PATHS="$GITHUB_WORKSPACE/x-wrt/package $GITHUB_WORKSPACE/x-wrt/feeds"

count_hans=0
count_cn=0
count_skipped=0

echo "=== 開始進行簡轉繁程序 ==="

for p in $TARGET_PATHS; do
    if [ -d "$p" ]; then
        echo "正在掃描目錄: $p"

        find "$p" -type f -name "*.po" | grep -E "(/zh_Hans/|/zh-cn/)" | while read -r s; do
            d=""
            type=""

            case "$s" in
                *"/zh_Hans/"*)
                    d=$(echo "$s" | sed 's/\/zh_Hans\//\/zh_Hant\//g')
                    type="hans"
                    ;;
                *"/zh-cn/"*)
                    d=$(echo "$s" | sed 's/\/zh-cn\//\/zh_TW\//g')
                    type="cn"
                    ;;
            esac

            if [ -n "$d" ]; then
                if [ -f "$d" ]; then
                    count_skipped=$((count_skipped + 1))
                else
                    mkdir -p "$(dirname "$d")"
                    echo "轉換中: $s -> $d"
                    opencc -i "$s" -o "$d" -c s2twp.json

                    if [ "$type" = "hans" ]; then
                        count_hans=$((count_hans + 1))
                    elif [ "$type" = "cn" ]; then
                        count_cn=$((count_cn + 1))
                    fi
                fi

                echo "$count_hans $count_cn $count_skipped" > /tmp/opencc_counts.tmp
            fi
        done
    fi
done

if [ -f /tmp/opencc_counts.tmp ]; then
    read -r final_hans final_cn final_skipped < /tmp/opencc_counts.tmp
    rm -f /tmp/opencc_counts.tmp
else
    final_hans=0
    final_cn=0
    final_skipped=0
fi

total=$((final_hans + final_cn))

echo "================================="
echo "=== 繁體語系檔案建置完成 ==="
echo "新轉換 zh_Hans -> zh_Hant 數量: $final_hans"
echo "新轉換 zh-cn   -> zh_TW   數量: $final_cn"
echo "已存在而跳過 (Skipped) 的檔案數: $final_skipped"
echo "本次成功新建立的檔案總數     : $total"
echo "================================="

cd /tmp/                                                                                                                                            
wget https://raw.githubusercontent.com/x-wrt/x-wrt/refs/heads/master/package/firmware/wireless-regdb/patches/600-custom-change-txpower-and-dfs.patch
wget https://raw.githubusercontent.com/x-wrt/x-wrt/refs/heads/master/package/firmware/wireless-regdb/patches/500-world-regd-5GHz.patch
mv /tmp/*.patch $GITHUB_WORKSPACE/x-wrt/package/firmware/wireless-regdb/patches/       
mv $GITHUB_WORKSPACE/patches/400-custom_hk-change-txpower-and-dfs.patch $GITHUB_WORKSPACE/x-wrt/package/firmware/wireless-regdb/patches/

unzip  $GITHUB_WORKSPACE/iCast.zip -d $GITHUB_WORKSPACE/x-wrt/package/kernel/
cd /home/runner/work/Actions-OpenWrt/Actions-OpenWrt/x-wrt

sed -i 's/+PACKAGE_icu:icu/+icu/' feeds/packages/net/samba4/Makefile


exit 0
