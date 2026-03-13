git clone https://github.com/openwrt/openwrt x-wrt
cp -r $GITHUB_WORKSPACE/myconfig/* $GITHUB_WORKSPACE/x-wrt/
sudo cp patches/copy_file.sh /usr/bin
cp patches/copy_file.sh x-wrt/
cd x-wrt
#kernel 250
#git checkout 57a6d97ddf8f6541a52e0f8fad8c6f47685a1bc3
#kernel 213
git checkout 8444302a92e601a1e05cb8468aaffa140d5a5b80



cp -r $GITHUB_WORKSPACE/package/* $GITHUB_WORKSPACE/x-wrt/package/

./scripts/feeds update -a               
./scripts/feeds install -a -f
cp config.aarch64.3 .config

rm target/linux/generic/backport-5.4/430-v6.3-ubi*.patch
rm target/linux/mvebu/patches-5.4/008-net-mvneta-make-tx-buffer-array-agnostic.patch
cd $GITHUB_WORKSPACE/x-wrt/
git clone https://github.com/tvheadend/tvheadend.git

cp -r $GITHUB_WORKSPACE/x-wrt/tvheadend/.git $GITHUB_WORKSPACE/x-wrt/package/tvheadend/files/
rm -r feeds/packages/multimedia/tvheadend
cp $GITHUB_WORKSPACE/patches/kernel-5.4 $GITHUB_WORKSPACE/x-wrt/include/
cp $GITHUB_WORKSPACE/patches/Makefile.rtl8821cu.5.4 $GITHUB_WORKSPACE/x-wrt/package/rtl8821cu/Makefile

##kernel 5.4.213 need to delete following patches
rm $GITHUB_WORKSPACE/x-wrt/target/linux/mvebu/patches-5.4/013-net-mvneta-rely-on-page_pool_recycle_direct-in-mvnet.patch
rm $GITHUB_WORKSPACE/x-wrt/target/linux/mvebu/patches-5.4/009-net-mvneta-add-XDP_TX-support.patch 
