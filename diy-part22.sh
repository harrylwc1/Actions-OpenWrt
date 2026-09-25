git clone https://github.com/openwrt/openwrt x-wrt
cp -r $GITHUB_WORKSPACE/myconfig/* $GITHUB_WORKSPACE/x-wrt/

sudo cp patches/copy_file.sh /usr/bin
cp patches/copy_file.sh x-wrt/
cd x-wrt
# 使用 cat 覆蓋或追加核心定義，確保 kmod-video-core 包含 mc.ko 並且依賴 kmod-media-core
#cat << 'EOF' >> package/kernel/linux/modules/video.mk

# 強制修正或確保 kmod-video-core 依賴項目內含 kmod-media-core
#define KernelPackage/video-core/depends
  #+kmod-media-core
#endef
#EOF

# 同時確保 kmod-media-core 套件有被正式納入編譯設定
#sed -i 's/AUTOLOAD:=$(call AutoLoad,25,videodev)/AUTOLOAD:=$(call AutoLoad,25,mc videodev)/g' package/kernel/linux/modules/video.mk

cp $GITHUB_WORKSPACE/patches/video.mk $GITHUB_WORKSPACE/x-wrt/package/kernel/linux/modules/
cp $GITHUB_WORKSPACE/patches/dvb.mk $GITHUB_WORKSPACE/x-wrt/package/kernel/linux/modules/

cd package 
git clone https://github.com/tmn505/openwrt-dvb
cp  $GITHUB_WORKSPACE/patches/Makefile.linuxtv $GITHUB_WORKSPACE/x-wrt/package/openwrt-dvb/linuxtv/Makefile
cd ..

#kernel 250
#git checkout 57a6d97ddf8f6541a52e0f8fad8c6f47685a1bc3
#kernel 213
git checkout 8444302a92e601a1e05cb8468aaffa140d5a5b80
##enable PLTS
sed -i 's/^# CONFIG_ARM_MODULE_PLTS is not set$/CONFIG_ARM_MODULE_PLTS=y/' target/linux/generic/config-5.4


#kernel 5.4.154 
#git checkout 2f04012b20515eec74563de74d0528e603aa6f89

cp -r $GITHUB_WORKSPACE/package/* $GITHUB_WORKSPACE/x-wrt/package/
#cd  $GITHUB_WORKSPACE/x-wrt/package/                                                    
#tar xvf kmod-dvb-combo.5.4.213.tar  
cd $GITHUB_WORKSPACE/x-wrt/

./scripts/feeds update -a               
./scripts/feeds install -a -f
#cp config.aarch64.3 .config

rm target/linux/generic/backport-5.4/430-v6.3-ubi*.patch
rm target/linux/mvebu/patches-5.4/008-net-mvneta-make-tx-buffer-array-agnostic.patch
cd $GITHUB_WORKSPACE/x-wrt/
git clone https://github.com/tvheadend/tvheadend.git

cp -r $GITHUB_WORKSPACE/x-wrt/tvheadend/.git $GITHUB_WORKSPACE/x-wrt/package/tvheadend/files/
rm -r feeds/packages/multimedia/tvheadend
cp $GITHUB_WORKSPACE/patches/kernel-5.4 $GITHUB_WORKSPACE/x-wrt/include/
#cp $GITHUB_WORKSPACE/patches/Makefile.rtl8821cu.5.4 $GITHUB_WORKSPACE/x-wrt/package/rtl8821cu/Makefile

sudo rm -r $GITHUB_WORKSPACE/x-wrt/package/libs/openssl/
cp -r $GITHUB_WORKSPACE/patches/openssl $GITHUB_WORKSPACE/x-wrt/package/libs/
##kernel 5.4.213 need to delete following patches
rm $GITHUB_WORKSPACE/x-wrt/target/linux/mvebu/patches-5.4/013-net-mvneta-rely-on-page_pool_recycle_direct-in-mvnet.patch
rm $GITHUB_WORKSPACE/x-wrt/target/linux/mvebu/patches-5.4/009-net-mvneta-add-XDP_TX-support.patch
cp $GITHUB_WORKSPACE/patches/Makefile.ccache tools/ccache/Makefile




# 1. 檢查並安裝 OpenCC
if ! command -v opencc >/dev/null 2>&1; then
    echo "找不到 OpenCC。正在安裝..."
    sudo apt-get update && sudo apt-get install -y opencc
fi

# 2. 定義要掃描的目錄
TARGET_PATHS="$GITHUB_WORKSPACE/x-wrt/package $GITHUB_WORKSPACE/x-wrt/feeds"

# 3. 初始化計數器
count_hans=0
count_cn=0
count_skipped=0

echo "=== 開始進行簡轉繁程序 ==="

for p in $TARGET_PATHS; do
    if [ -d "$p" ]; then
        echo "正在掃描目錄: $p"

        # 尋找所有 .po 檔案，並過濾路徑中包含 zh_Hans 或 zh-cn 的檔案
        find "$p" -type f -name "*.po" | grep -E "(/zh_Hans/|/zh-cn/)" | while read -r s; do
            d=""
            type=""

            # 依據資料夾名稱決定輸出的繁體資料夾
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

            # 如果路徑匹配成功
            if [ -n "$d" ]; then
                # 【新增檢查】：如果目標繁體檔案已經存在，則跳過不處理
                if [ -f "$d" ]; then
                    count_skipped=$((count_skipped + 1))
                else
                    # 建立新資料夾並執行轉換
                    mkdir -p "$(dirname "$d")"
                    echo "轉換中: $s -> $d"
                    opencc -i "$s" -o "$d" -c s2twp.json

                    # 記錄成功轉換次數
                    if [ "$type" = "hans" ]; then
                        count_hans=$((count_hans + 1))
                    elif [ "$type" = "cn" ]; then
                        count_cn=$((count_cn + 1))
                    fi
                fi

                # 將最新計數寫入暫存檔
                echo "$count_hans $count_cn $count_skipped" > /tmp/opencc_counts.tmp
            fi
        done
    fi
done

# 讀取最終統計數量
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






#cat GITHUB_WORKSPACE/myconfig/lang.update >> feeds/luci/modules/luci-mod-status/po/zh_Hant/status.po

if [ "$CPU_MULTI_CORE" = "true" ]; then
    echo "==> CPU_MULTI_CORE=true，应用多核 top 补丁"

    SRC_DIR="${GITHUB_WORKSPACE}/myconfig"
    LUCI_DIR="${GITHUB_WORKSPACE}/x-wrt/feeds/luci"

    # ---------- sys.lua ----------
    SYS_LUA="$LUCI_DIR/modules/luci-lua-runtime/luasrc/sys.lua"
    [ -f "$SYS_LUA.orig" ] || cp -f "$SYS_LUA" "$SYS_LUA.orig"
    cp -f "$SRC_DIR/sys.lua" "$SYS_LUA"
    echo "    已覆盖: $SYS_LUA"

    # ---------- processes.js ----------
    PROCESSES_JS="$LUCI_DIR/modules/luci-mod-status/htdocs/luci-static/resources/view/status/processes.js"
    [ -f "$PROCESSES_JS.orig" ] || cp -f "$PROCESSES_JS" "$PROCESSES_JS.orig"
    cp -f "$SRC_DIR/processes.js" "$PROCESSES_JS"
    echo "    已覆盖: $PROCESSES_JS"

    # ---------- sys.uc（仅当 ucode 目录存在） ----------
    if [ -d "$LUCI_DIR/modules/luci-base/ucode" ]; then
        SYS_UC="$LUCI_DIR/modules/luci-base/ucode/sys.uc"
        [ -f "$SYS_UC.orig" ] || cp -f "$SYS_UC" "$SYS_UC.orig"
        cp -f "$SRC_DIR/sys.uc" "$SYS_UC"
        echo "    已覆盖: $SYS_UC"
    else
        echo "    未检测到 ucode 目录，跳过 sys.uc"
    fi

    # ---------- base.po 翻译 ----------
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



sed -i 's|TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include|TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include -Wno-array-bounds|g' package/network/services/umdns/Makefile
